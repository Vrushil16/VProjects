import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:v_projects/utils/responsive_widget.dart';
import 'package:video_player/video_player.dart';

class MediaDisplayScreen extends StatefulWidget {
  @override
  _MediaDisplayScreenState createState() => _MediaDisplayScreenState();
}

class _MediaDisplayScreenState extends State<MediaDisplayScreen> {
  List<String> imageUrls = [];
  List<String> videoUrls = [];
  List<String> pdfUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    final ListResult result = await FirebaseStorage.instance.ref('Projects/P1/P_I_V_P').listAll();

    List<String> images = [];
    List<String> videos = [];
    List<String> pdfs = [];

    for (var ref in result.items) {
      String url = await ref.getDownloadURL();
      if (ref.name.endsWith('.jpg') || ref.name.endsWith('.png')) {
        images.add(url);
      } else if (ref.name.endsWith('.mp4')) {
        videos.add(url);
      } else if (ref.name.endsWith('.pdf')) {
        pdfs.add(url);
      }
    }

    setState(() {
      imageUrls = images;
      videoUrls = videos;
      pdfUrls = pdfs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Media Display")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ResponsiveWidget(
              largeScreen: buildLargeScreen(),
              mediumScreen: buildMediumScreen(),
              smallScreen: buildSmallScreen(),
            ),
    );
  }

  Widget buildLargeScreen() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: imageUrls.length + videoUrls.length + pdfUrls.length,
      itemBuilder: (context, index) {
        if (index < imageUrls.length) {
          return Image.network(imageUrls[index], fit: BoxFit.cover);
        } else if (index < imageUrls.length + videoUrls.length) {
          return buildVideoPlayer(videoUrls[index - imageUrls.length]);
        } else {
          return buildPdfViewer(pdfUrls[index - imageUrls.length - videoUrls.length]);
        }
      },
    );
  }

  Widget buildMediumScreen() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: imageUrls.length + videoUrls.length + pdfUrls.length,
      itemBuilder: (context, index) {
        if (index < imageUrls.length) {
          return Image.network(imageUrls[index], fit: BoxFit.cover);
        } else if (index < imageUrls.length + videoUrls.length) {
          return buildVideoPlayer(videoUrls[index - imageUrls.length]);
        } else {
          return buildPdfViewer(pdfUrls[index - imageUrls.length - videoUrls.length]);
        }
      },
    );
  }

  Widget buildSmallScreen() {
    return ListView.builder(
      itemCount: imageUrls.length + videoUrls.length + pdfUrls.length,
      itemBuilder: (context, index) {
        if (index < imageUrls.length) {
          return Image.network(imageUrls[index], fit: BoxFit.cover);
        } else if (index < imageUrls.length + videoUrls.length) {
          return buildVideoPlayer(videoUrls[index - imageUrls.length]);
        } else {
          return buildPdfViewer(pdfUrls[index - imageUrls.length - videoUrls.length]);
        }
      },
    );
  }

  Widget buildVideoPlayer(String url) {
    VideoPlayerController controller = VideoPlayerController.network(url);
    return FutureBuilder(
      future: controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildPdfViewer(String url) {
    return ElevatedButton(
      onPressed: () async {
        final Uri pdfUri = Uri.parse(url);
        if (await canLaunch(pdfUri.toString())) {
          await launch(pdfUri.toString());
        } else {
          throw 'Could not launch $pdfUri';
        }
      },
      child: Text("View PDF"),
    );
  }
}
