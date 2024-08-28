import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:v_projects/utils/responsive_widget.dart';

class ProjectListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Projects')),
      body: ListView(
        children: [
          ListTile(
            title: Text('CCC'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MediaDisplayScreen(
                    folderPath: 'Projects/P1/P_I_V_P',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MediaDisplayScreen extends StatefulWidget {
  final String folderPath;

  MediaDisplayScreen({required this.folderPath});

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
    final ListResult result = await FirebaseStorage.instance.ref(widget.folderPath).listAll();

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
      appBar: AppBar(
        title: Text("Media Display", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blueGrey))
          : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 1200) {
                  return buildGridView(crossAxisCount: 4);
                } else if (constraints.maxWidth >= 800) {
                  return buildGridView(crossAxisCount: 3);
                } else {
                  return buildListView();
                }
              },
            ),
    );
  }

  Widget buildGridView({required int crossAxisCount}) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: imageUrls.length + videoUrls.length + pdfUrls.length,
      itemBuilder: (context, index) {
        if (index < imageUrls.length) {
          return buildMediaCard(url: imageUrls[index], mediaType: 'image');
        } else if (index < imageUrls.length + videoUrls.length) {
          return buildMediaCard(url: videoUrls[index - imageUrls.length], mediaType: 'video');
        } else {
          return buildMediaCard(url: pdfUrls[index - imageUrls.length - videoUrls.length], mediaType: 'pdf');
        }
      },
    );
  }

  Widget buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: imageUrls.length + videoUrls.length + pdfUrls.length,
      itemBuilder: (context, index) {
        if (index < imageUrls.length) {
          return buildMediaCard(url: imageUrls[index], mediaType: 'image', isListView: true);
        } else if (index < imageUrls.length + videoUrls.length) {
          return buildMediaCard(url: videoUrls[index - imageUrls.length], mediaType: 'video', isListView: true);
        } else {
          return buildMediaCard(url: pdfUrls[index - imageUrls.length - videoUrls.length], mediaType: 'pdf', isListView: true);
        }
      },
    );
  }

  Widget buildMediaCard({required String url, required String mediaType, bool isListView = false}) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                height: isListView ? 150 : double.infinity,
                width: double.infinity,
                placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.blueGrey)),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              if (mediaType == 'video') Icon(Icons.play_circle_outline, color: Colors.white, size: 50),
              if (mediaType == 'pdf') Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 50),
            ],
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
