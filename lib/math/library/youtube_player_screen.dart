// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class YoutubePlayerScreen extends StatefulWidget {
//   final String videoUrl;

//   const YoutubePlayerScreen({super.key, required this.videoUrl});

//   @override
//   State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
// }

// class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
//   late YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? '';
//     _controller = YoutubePlayerController(
//       initialVideoId: videoId,
//       flags: const YoutubePlayerFlags(
//         autoPlay: true,
//         mute: false,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Watch Video"),
//         backgroundColor: const Color(0xFFFFA726),
//       ),
//       body: YoutubePlayerBuilder(
//         player: YoutubePlayer(controller: _controller),
//         builder: (context, player) => Center(child: player),
//       ),
//     );
//   }
// }
