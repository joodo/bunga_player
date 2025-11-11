import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

String generateUsername(String seed) {
  final bytes = utf8.encode(seed);
  final digest = md5.convert(bytes);
  final hashNum = digest.bytes.fold<int>(0, (a, b) => a + b);
  final random = Random(hashNum);

  final adjectives = [
    '新鲜的',
    '翠绿的',
    '香脆的',
    '可爱的',
    '胖乎乎的',
    '迷你的',
    '多汁的',
    '爽口的',
    '甜甜的',
    '圆滚滚的',
    '沉默的',
    '热情的',
    '神秘的',
    '快乐的'
  ];

  final vegetables = [
    '白菜',
    '黄瓜',
    '萝卜',
    '茄子',
    '西红柿',
    '土豆',
    '南瓜',
    '辣椒',
    '洋葱',
    '豆芽',
    '芹菜',
    '生菜',
    '空心菜',
    '紫甘蓝',
    '西兰花',
    '香菜',
    '蒜苗'
  ];

  final adj = adjectives[random.nextInt(adjectives.length)];
  final veg = vegetables[random.nextInt(vegetables.length)];
  final number = random.nextInt(9999).toString().padLeft(4, '0');

  return '$adj$veg$number';
}
