import 'package:flutter/material.dart';

class BungaHero extends StatelessWidget {
  final String tag;
  final Widget child;

  const BungaHero({super.key, required this.tag, required this.child});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      // 1. 强制使用 M3 的弧形路径
      createRectTween: (begin, end) =>
          MaterialRectArcTween(begin: begin, end: end),

      // 2. 自定义飞行过程，解决 BoxFit 突变
      flightShuttleBuilder:
          (flightContext, animation, direction, fromContext, toContext) {
            // 使用间隔动画 (Interval) 来实现 M3 典型的淡入淡出过渡
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return Opacity(
                  opacity: 1.0,
                  child: Image.network(
                    tag, // 假设 tag 就是 URL
                    fit: BoxFit.cover, // 飞行中保持 cover 避免拉伸
                  ),
                );
              },
            );
          },
      child: child,
    );
  }
}
