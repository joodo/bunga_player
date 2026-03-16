# Playback Synchronization

## Status Heartbeat

Every second, each client sends a `ClientStatusMessageData` heartbeat to the server with a single boolean field `isPending`. A client is considered **pending** (not ready) if any of the following is true:

- The video has not finished loading (`duration == Duration.zero`)
- The buffer lead ahead of the current position is less than 1 second
- The user is actively dragging the seek slider

The server broadcasts a `ChannelStatusMessageData` each second to all clients. This message contains:

- `watcherIds` — all connected client IDs
- `readyIds` — clients that are not pending
- `position` — the canonical channel playback position
- `playStatus` — one of `paused`, `pending`, or `playing`

The set difference `watcherIds − readyIds` gives the currently buffering clients, shown as a loading indicator in the UI.

## Status Synchronization

Most of the time, each client reconciles its local position against the channel's authoritative position carried in `ChannelStatusMessageData`. The response depends on the absolute delta between the two positions:

| Delta (`∆ = \|local − channel\|`) | Condition                       | Action                                                         |
| --------------------------------- | ------------------------------- | -------------------------------------------------------------- |
| `∆ < 400 ms`                      | —                               | Treat as in sync; set rate to `1.0`                            |
| `400 ms ≤ ∆ < 3 s`                | —                               | Silent catch-up; set rate to `0.95` (ahead) or `1.05` (behind) |
| `3 s ≤ ∆ < 7 s`                   | Playing and client is **ahead** | Pause the client to wait for others                            |
| All other cases                   | —                               | Hard seek to channel position                                  |

> These thresholds correspond to the `_Tolerances` enum: `treatAsSync` (400 ms), `silenceCatchUp` (3 s), and `waitForOthers` (7 s).

## Playback Actions

### Pause

The operator's own client pauses immediately — `MediaPlayer.pause()` is called directly before the `PauseMessageData` (carrying the current position) is sent, without waiting for a round-trip. Remote clients that receive this message also pause immediately and, if their local position differs from the carried position by more than 400 ms, seek to that position. This ensures all clients land on the same frame without waiting for the next heartbeat cycle.

### Play

Pressing play sends a `PlayMessageData` and shows a **pending** overlay in the UI. No actual `MediaPlayer.play()` call is made at this point. The real playback start is driven by the next `ChannelStatusMessageData` heartbeat, once the channel's `playStatus` becomes `playing` and the client is in sync.

### Seek

When a seek starts, the client enters an **autonomous mode**: the `_isChannelSeeking` flag is raised and channel-status-driven synchronization is suppressed. The client applies every seek immediately without waiting for the server. This flag is backed by an auto-resetting notifier with a **5-second timeout** from the last seek event; once it expires, normal synchronization resumes.
