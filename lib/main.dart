import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mlkit/mlkit.dart';
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _file;

  List<VisionFace> _face = <VisionFace>[];

  VisionFaceDetectorOptions options = new VisionFaceDetectorOptions(
      modeType: VisionFaceDetectorMode.Accurate,
      landmarkType: VisionFaceDetectorLandmark.All,
      classificationType: VisionFaceDetectorClassification.All,
      minFaceSize: 0.15,
      isTrackingEnabled: true);

  FirebaseVisionFaceDetector detector = FirebaseVisionFaceDetector.instance;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: new Scaffold(
        appBar: new AppBar(
          backgroundColor: Color(0xffFC6E20),
          title: new Text(
            'Face Detection Firebase',
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
        body: showBody(_file),
        floatingActionButton: new FloatingActionButton(
          backgroundColor: Color(0xffFC6E20),
          onPressed: () async {
            var file = await ImagePicker.pickImage(source: ImageSource.gallery);
            setState(() {
              _file = file;
            });

            print("Welcome");
            var face = await detector.detectFromBinary(
                _file?.readAsBytesSync(), options);
            print(face);
            setState(() {
              if (face.isEmpty) {
                print('No face detected');
              } else {
                _face = face;
              }
            });
          },
          child: new Icon(Icons.tag_faces),
        ),
      ),
    );
  }

  Widget showBody(File file) {
    return new Container(
      child: new Stack(
        children: <Widget>[
          _buildImage(),
          _showDetails(_face),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return new SizedBox(
      height: 500.0,
      child: new Center(
        child: _file == null
            ? new Text(
                'Select image using Floating Button...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
              )
            : new FutureBuilder<Size>(
                future: _getImageSize(Image.file(_file, fit: BoxFit.fitWidth)),
                builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        foregroundDecoration:
                            TextDetectDecoration(_face, snapshot.data),
                        child: Image.file(_file, fit: BoxFit.fitWidth));
                  } else {
                    return new Text('Please wait...');
                  }
                },
              ),
      ),
    );
  }
}

class TextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionFace> _texts;
  TextDetectDecoration(List<VisionFace> texts, Size originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return new _TextDetectPainter(_texts, _originalImageSize);
  }
}

Future _getImageSize(Image image) {
  Completer<Size> completer = new Completer<Size>();
  image.image.resolve(new ImageConfiguration()).addListener(ImageStreamListener(
      (ImageInfo info, bool _) => completer.complete(
          Size(info.image.width.toDouble(), info.image.height.toDouble()))));
  return completer.future;
}

Widget _showDetails(List<VisionFace> faceList) {
  if (faceList == null || faceList.length == 0) {
    return new Text(
      '',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

   if(faceList[0].smilingProbability >= 0.8){
      print("5 Star Rating");
    }
    else if(faceList[0].smilingProbability < 0.8 && faceList[0].smilingProbability >=0.6){
      print("4 Star Rating");
    }
    else if(faceList[0].smilingProbability < 0.6 && faceList[0].smilingProbability >=0.4){
      print("3 Star Rating");
    }
    else if(faceList[0].smilingProbability < 0.4 && faceList[0].smilingProbability >=0.2){
      print("2 Star Rating");
    }
    else{
      print("1 Star Rating");
    }
    double sum = 0;
    double avgs=0;
  return new Container(
    child: new ListView.builder(
      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 500),
      itemCount: faceList.length,
      itemBuilder: (context, i) {
        checkData(faceList);
        sum+=faceList[i].smilingProbability;
        avgs = sum/faceList.length;
        print("Total No of Person in Frame are :nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
        print(faceList.length);
        return _buildRow(
            faceList[i].hasLeftEyeOpenProbability,
            faceList[i].headEulerAngleY,
            faceList[i].headEulerAngleZ,
            faceList[i].leftEyeOpenProbability,
            faceList[i].rightEyeOpenProbability,
            faceList[i].smilingProbability,
            avgs,
            faceList[i].trackingID,
        );
      },
    ),

  );
}

//For checking and printing different variables from Firebase
void checkData(List<VisionFace> faceList) {
  final double uncomputedProb = -1.0;
  final int uncompProb = -1;

  for (int i = 0; i < faceList.length; i++) {
    Rect bounds = faceList[i].rect;
    print('Rectangle : $bounds');

    VisionFaceLandmark landmark =
        faceList[i].getLandmark(FaceLandmarkType.LeftEar);

    if (landmark != null) {
      VisionPoint leftEarPos = landmark.position;
      print('Left Ear Pos : $leftEarPos');
    }

    if (faceList[i].smilingProbability != uncomputedProb) {
      double smileProb = faceList[i].smilingProbability;
      print('Smile Prob : $smileProb');
    }

    if (faceList[i].rightEyeOpenProbability != uncomputedProb) {
      double rightEyeOpenProb = faceList[i].rightEyeOpenProbability;
      print('RightEye Open Prob : $rightEyeOpenProb');
    }

    if (faceList[i].trackingID != uncompProb) {
      int tID = faceList[i].trackingID;
      print('Tracking ID : $tID');
    }
  }
}

/*
    HeadEulerY : Head is rotated to right by headEulerY degrees
    HeadEulerZ : Head is tilted sideways by headEulerZ degrees
    LeftEyeOpenProbability : left Eye Open Probability
    RightEyeOpenProbability : right Eye Open Probability
    SmilingProbability : Smiling probability
    Tracking ID : If face tracking is enabled
  */
Widget _buildRow(
    bool leftEyeProb,
    double headEulerY,
    double headEulerZ,
    double leftEyeOpenProbability,
    double rightEyeOpenProbability,
    double smileProb,
    double avg,
    int tID) {
  return ListTile(
    title: new Text(
      "\nLeftEyeProb: $leftEyeProb \nHeadEulerY : $headEulerY \nHeadEulerZ : $headEulerZ \nLeftEyeOpenProbability : $leftEyeOpenProbability \nRightEyeOpenProbability : $rightEyeOpenProbability \nSmileProb : $smileProb \nFaceTrackingEnabled : $tID \naverage :$avg",
    ),
    dense: true,
  );
}

class _TextDetectPainter extends BoxPainter {
  final List<VisionFace> _faceLabels;
  final Size _originalImageSize;
  _TextDetectPainter(faceLabels, originalImageSize)
      : _faceLabels = faceLabels,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = new Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var faceLabel in _faceLabels) {
      final _rect = Rect.fromLTRB(
          offset.dx + faceLabel.rect.left / _widthRatio,
          offset.dy + faceLabel.rect.top / _heightRatio,
          offset.dx + faceLabel.rect.right / _widthRatio,
          offset.dy + faceLabel.rect.bottom / _heightRatio);

      canvas.drawRect(_rect, paint);
    }
  }
}
