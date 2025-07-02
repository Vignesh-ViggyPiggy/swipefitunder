// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:swipefit/resources/auth_methods.dart';
// import 'dart:async';
// import '../provider/provider.dart'; // Adjust the path as necessary

// class FriendsPage extends ConsumerStatefulWidget {
//   @override
//   _FriendsPageState createState() => _FriendsPageState();
// }

// class _FriendsPageState extends ConsumerState<FriendsPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   Timer? _debounce;
//   String _searchQuery = '';
//   String? _selectedUid;
//   String? _currentUserUid;
//   Map<String, String> _usernamesMap = {};
//   List<String> _sentRequests = [];
//   List<String> _friends = [];
//   String? _selectedFriendUid;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _fetchCurrentUser();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _fetchCurrentUser();
//   }

//   Future<void> _fetchCurrentUser() async {
//     final userId = await ref.read(useridProvider.future);
//     setState(() {
//       _currentUserUid = userId;
//     });
//     _fetchSentRequests(userId);
//     _fetchFriends(userId);
//   }

//   Future<void> _fetchSentRequests(String uid) async {
//     final sentRequests = await AuthMethods().fetchSentRequests(uid);
//     setState(() {
//       _sentRequests = sentRequests;
//     });
//   }

//   Future<void> _fetchFriends(String uid) async {
//     final friends = await AuthMethods().fetchFriends(uid);
//     final friendsUsernamesMap =
//         await AuthMethods().getUsernamesFromUids(friends);
//     setState(() {
//       _friends = friends;
//       _usernamesMap.addAll(friendsUsernamesMap);
//     });
//   }

//   Future<void> _removeFriend() async {
//     if (_currentUserUid != null && _selectedFriendUid != null) {
//       await AuthMethods().removeFriend(_currentUserUid!, _selectedFriendUid!);
//       setState(() {
//         _friends.remove(_selectedFriendUid);
//         _selectedFriendUid = null;
//       });
//     }
//   }

//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//     _debounce = Timer(const Duration(seconds: 1), () {
//       setState(() {
//         _searchQuery = query.toLowerCase();
//       });
//     });
//   }

//   void _onUserSelected(String uid) {
//     setState(() {
//       _selectedUid = uid;
//     });
//   }

//   Future<void> _onSendPressed(String selectedUid) async {
//     if (_currentUserUid != null) {
//       await AuthMethods().sendFriendRequest(_currentUserUid!, selectedUid);
//       setState(() {
//         _sentRequests.add(selectedUid);
//       });
//     }
//   }

//   Future<void> _onUnsendPressed(String selectedUid) async {
//     if (_currentUserUid != null) {
//       await AuthMethods().undoFriendRequest(_currentUserUid!, selectedUid);
//       setState(() {
//         _sentRequests.remove(selectedUid);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final usernamesAsyncValue = _searchQuery.length >= 3
//         ? ref.watch(usernamesProvider(_searchQuery))
//         : AsyncValue.data({});

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Friends'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(text: 'Search'),
//             Tab(text: 'Friends'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           // Search Tab
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   onChanged: _onSearchChanged,
//                   decoration: InputDecoration(
//                     hintText: 'Search...',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.search),
//                   ),
//                 ),
//               ),
//               usernamesAsyncValue.when(
//                 data: (usernamesMap) {
//                   final usernames = usernamesMap.keys.toList();
//                   if (usernames.length > 5) {
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Search to find your friend'),
//                     );
//                   } else {
//                     return Expanded(
//                       child: ListView.builder(
//                         itemCount: usernames.length,
//                         itemBuilder: (context, index) {
//                           final username = usernames[index];
//                           final uid = usernamesMap[username]!;
//                           final isCurrentUser = uid == _currentUserUid;
//                           final hasSentRequest = _sentRequests.contains(uid);
//                           final isFriend = _friends.contains(uid);
//                           return ListTile(
//                             title: Text(
//                                 isCurrentUser ? '$username (Me)' : username),
//                             leading: CircleAvatar(
//                               backgroundColor: Colors.grey[800],
//                               child: Text(
//                                 username.isNotEmpty
//                                     ? username[0].toUpperCase()
//                                     : '?',
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                             trailing: isCurrentUser || isFriend
//                                 ? null
//                                 : ElevatedButton(
//                                     onPressed: hasSentRequest
//                                         ? () => _onUnsendPressed(uid)
//                                         : () => _onSendPressed(uid),
//                                     child: Text(
//                                         hasSentRequest ? 'Unsend' : 'Send'),
//                                     style: ElevatedButton.styleFrom(
//                                       foregroundColor: hasSentRequest
//                                           ? Colors.red
//                                           : Colors.green,
//                                       backgroundColor: Colors.grey[800],
//                                     ),
//                                   ),
//                             selected: _selectedUid == uid,
//                             onTap: () => _onUserSelected(uid),
//                           );
//                         },
//                       ),
//                     );
//                   }
//                 },
//                 loading: () => Center(child: CircularProgressIndicator()),
//                 error: (err, stack) => Center(child: Text('Error: $err')),
//               ),
//             ],
//           ),
//           // Friends Tab
//           ListView.builder(
//             itemCount: _friends.length,
//             itemBuilder: (context, index) {
//               final friendUid = _friends[index];
//               final friendUsername = _usernamesMap.entries
//                   .firstWhere((entry) => entry.value == friendUid,
//                       orElse: () => MapEntry('Unknown', friendUid))
//                   .key;
//               final isSelected = _selectedFriendUid == friendUid;

//               return ListTile(
//                 title: Text(friendUsername),
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.grey[800],
//                   child: Text(
//                     friendUsername.isNotEmpty
//                         ? friendUsername[0].toUpperCase()
//                         : '?',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 trailing: isSelected
//                     ? ElevatedButton(
//                         onPressed: _removeFriend,
//                         child: Text('Remove Friend'),
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: Colors.red,
//                           backgroundColor: Colors.grey[800],
//                         ),
//                       )
//                     : null,
//                 selected: isSelected,
//                 onTap: () => setState(() {
//                   _selectedFriendUid = isSelected ? null : friendUid;
//                 }),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipefit/resources/auth_methods.dart';
import 'dart:async';
import '../provider/provider.dart'; // Adjust the path as necessary

class FriendsPage extends ConsumerStatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends ConsumerState<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _debounce;
  String _searchQuery = '';
  String? _selectedUid;
  String? _currentUserUid;
  Map<String, String> _usernamesMap = {};
  List<String> _sentRequests = [];
  List<String> _friends = [];
  String? _selectedFriendUid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final userId = await ref.read(useridProvider.future);
    setState(() {
      _currentUserUid = userId;
    });
    _fetchSentRequests(userId);
    _fetchFriends(userId);
  }

  Future<void> _fetchSentRequests(String uid) async {
    final sentRequests = await AuthMethods().fetchSentRequests(uid);
    setState(() {
      _sentRequests = sentRequests;
    });
  }

  Future<void> _fetchFriends(String uid) async {
    try {
      // Fetch the list of friend UIDs
      final friends = await AuthMethods().fetchFriends(uid);
      //print('Fetched friends: $friends');

      // Fetch the usernames for the friend UIDs
      final friendsUsernamesMap =
          await AuthMethods().getUsernamesFromUids(friends);
      print('Fetched friends usernames: $friendsUsernamesMap');

      setState(() {
        _friends = friends; // Update the _friends list with UIDs
        _usernamesMap.addAll(friendsUsernamesMap); // Add usernames to the map
      });
      print('Updated _friends: $_friends');
      print('Updated _usernamesMap: $_usernamesMap');
    } catch (e) {
      print('Error fetching friends: $e');
    }
  }

  Future<void> _removeFriend(String friendUid) async {
    if (_currentUserUid != null) {
      await AuthMethods().removeFriend(_currentUserUid!, friendUid);
      setState(() {
        _friends.remove(friendUid);
        _selectedFriendUid = null;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
    });
  }

  void _onUserSelected(String uid) {
    setState(() {
      _selectedUid = uid;
    });
  }

  Future<void> _onSendPressed(String selectedUid) async {
    if (_currentUserUid != null) {
      await AuthMethods().sendFriendRequest(_currentUserUid!, selectedUid);
      setState(() {
        _sentRequests.add(selectedUid);
      });
    }
  }

  Future<void> _onUnsendPressed(String selectedUid) async {
    if (_currentUserUid != null) {
      await AuthMethods().undoFriendRequest(_currentUserUid!, selectedUid);
      setState(() {
        _sentRequests.remove(selectedUid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final usernamesAsyncValue = _searchQuery.length >= 0
        ? ref.watch(usernamesProvider(_searchQuery))
        : AsyncValue.data({});

    // print('Friends: $_friends');
    // print('Usernames Map: $_usernamesMap');
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Search'),
            Tab(text: 'Friends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Search Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              usernamesAsyncValue.when(
                data: (usernamesMap) {
                  final usernames = usernamesMap.keys.toList();
                  return Expanded(
                    child: ListView.builder(
                      itemCount: usernames.length,
                      itemBuilder: (context, index) {
                        final username = usernames[index];
                        final uid = usernamesMap[username]!;
                        final isCurrentUser = uid == _currentUserUid;
                        final isFriend = _friends.contains(uid);
                        final hasSentRequest = _sentRequests.contains(uid);

                        return ListTile(
                          title: Text(
                            isCurrentUser ? '$username (Me)' : username,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            child: Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          trailing: isCurrentUser || isFriend
                              ? null // Remove the button if the user is the current user or already a friend
                              : ElevatedButton(
                                  onPressed: hasSentRequest
                                      ? () => _onUnsendPressed(uid)
                                      : () => _onSendPressed(uid),
                                  child:
                                      Text(hasSentRequest ? 'Unsend' : 'Send'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: hasSentRequest
                                        ? Colors.red
                                        : Colors.green,
                                    backgroundColor: Colors.grey[800],
                                  ),
                                ),
                          selected: _selectedUid == uid,
                          onTap: () => _onUserSelected(uid),
                        );
                      },
                    ),
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ],
          ),
          // Friends Tab
          ListView.builder(
            itemCount: _friends.length,
            itemBuilder: (context, index) {
              final friendUid = _friends[index];
              final friendUsername = _usernamesMap.entries
                  .firstWhere((entry) => entry.value == friendUid,
                      orElse: () => MapEntry('Unknown', friendUid))
                  .key;

              return ListTile(
                title: Text(friendUsername),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: Text(
                    friendUsername.isNotEmpty
                        ? friendUsername[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () => _removeFriend(friendUid),
                  child: const Text('Remove Friend'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.grey[800],
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
