// import 'package:flutter/material.dart';
// import 'package:swipefit/provider/CardProvider.dart';
// import 'package:provider/provider.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<CardProvider>(context, listen: false);
//       provider.resetUsers();
//     });
//   }

//   Future<void> _refresh() async {
//     // final provider = Provider.of<CardProvider>(context, listen: false);
//     // provider.resetUsers();
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         color: Colors.blue,
//         backgroundColor: Colors.white,
//         child: Consumer<CardProvider>(
//           builder: (context, provider, child) {
//             return CustomScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               slivers: [
//                 SliverFillRemaining(
//                   child: provider.urlImages.isEmpty
//                       ? Center(
//                           child: ElevatedButton(
//                             onPressed: _refresh,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   const Color.fromARGB(255, 18, 18, 18),
//                             ),
//                             child: const Text('Empty Feed'),
//                           ),
//                         )
//                       : Stack(
//                           fit: StackFit.expand,
//                           children: provider.urlImages
//                               .map((urlImage) {
//                                 final picUrl = urlImage['pic_url'];
//                                 final pid = urlImage['pid'];
//                                 if (picUrl == null || pid == null) {
//                                   // Skip this item if required data is missing
//                                   return const Center(
//                                     child: Text(
//                                       "No Picture",
//                                       style: TextStyle(color: Colors.white),
//                                     ),
//                                   );
//                                 }
//                                 //return TinderCard(
//                                   urlImage: picUrl,
//                                   isFront: provider.urlImages.last == urlImage,
//                                   prid: pid,
//                                 );
//                               })
//                               .whereType<Widget>() // Filter out null widgets
//                               .toList(),
//                         ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
