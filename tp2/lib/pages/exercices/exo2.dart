import 'dart:async';
import 'package:flutter/material.dart';

class Exo2Page extends StatefulWidget {
  const Exo2Page({super.key});

  @override
  _Exo2PageState createState() => _Exo2PageState();
}

class _Exo2PageState extends State<Exo2Page> {
  double _rotationX = 0;
  double _rotationY = 0;
  double _rotationZ = 0;
  double _scale = 1;
  bool _isMirrored = false;
  bool _isAnimating = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    const d = Duration(milliseconds: 50);
    _timer = Timer.periodic(d, animate);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void animate(Timer t) {
    if (_isAnimating) {
      setState(() {
        _rotationX += 0.01;
        _rotationY += 0.01;
        _rotationZ += 0.01;
        if (_rotationX > 6.28) _rotationX = 0;
        if (_rotationY > 6.28) _rotationY = 0;
        if (_rotationZ > 6.28) _rotationZ = 0;
      });
    }
  }

  void toggleAnimation() {
    setState(() {
      _isAnimating = !_isAnimating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercice 2'),
        actions: [
          IconButton(
            icon: Icon(_isAnimating ? Icons.pause : Icons.play_arrow),
            onPressed: toggleAnimation,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Transform(
                  transform: Matrix4.identity()
                    ..rotateX(_rotationX)
                    ..rotateY(_rotationY)
                    ..rotateZ(_rotationZ)
                    ..scale(_scale * (_isMirrored ? -1 : 1), _scale),
                  alignment: Alignment.center,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image.asset('../../assets/exo2.jpg'),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Rotation X', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _rotationX,
              min: 0,
              max: 6.28, // 2 * pi radians
              onChanged: (value) {
                setState(() {
                  _rotationX = value;
                });
              },
              label: 'Rotation X',
            ),
            Text('Rotation Y', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _rotationY,
              min: 0,
              max: 6.28, // 2 * pi radians
              onChanged: (value) {
                setState(() {
                  _rotationY = value;
                });
              },
              label: 'Rotation Y',
            ),
            Text('Rotation Z', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _rotationZ,
              min: 0,
              max: 6.28, // 2 * pi radians
              onChanged: (value) {
                setState(() {
                  _rotationZ = value;
                });
              },
              label: 'Rotation Z',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Mirror', style: TextStyle(fontWeight: FontWeight.bold)),
                Checkbox(
                  value: _isMirrored,
                  onChanged: (value) {
                    setState(() {
                      _isMirrored = value!;
                    });
                  },
                ),
              ],
            ),
            Text('Scale', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _scale,
              min: 0.5,
              max: 2,
              onChanged: (value) {
                setState(() {
                  _scale = value;
                });
              },
              label: 'Scale',
            ),
          ],
        ),
      ),
    );
  }
}