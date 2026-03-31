import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/screens/social/user_search_page.dart';
import 'package:powerank/screens/workout/create_workout_page.dart';
import 'package:powerank/widgets/app_drawer.dart';
import 'package:powerank/widgets/notification_menu_button.dart';
import 'package:powerank/widgets/workout_post_card.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  bool _checkedInToday = false;
  String? _todayWorkoutTitle;
  bool _savingCheckIn = false;

  @override
  void initState() {
    super.initState();
    _loadTodayCheckIn();
  }

  String _todayKey() {
    final today = DateTime.now();
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  WorkoutPost _postFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return WorkoutPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      user: (data['username'] ?? 'Utilizador').toString(),
      time: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate().toString()
          : 'agora',
      title: data['title'] ?? '',
      exercises: List<Map<String, dynamic>>.from(
        (data['exercises'] ?? []).map(
          (e) => e is Map<String, dynamic>
              ? e
              : Map<String, dynamic>.from(e as Map),
        ),
      ),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      videoUrls: List<String>.from(data['videoUrls'] ?? []),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      commentsList: [],
      likedBy: List<String>.from(data['likedBy'] ?? []),
      totalWeight: (data['totalWeight'] ?? 0).toDouble(),
    );
  }

  Future<void> _loadTodayCheckIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('checkins').doc(user.uid).get();

    final data = doc.data() ?? {};
    final entries = Map<String, dynamic>.from(data['entries'] ?? {});
    final todayEntry = entries[_todayKey()];

    if (!mounted) return;

    if (todayEntry is Map) {
      final entry = Map<String, dynamic>.from(todayEntry);
      setState(() {
        _checkedInToday = true;
        _todayWorkoutTitle = entry['workoutTitle']?.toString();
      });
    } else {
      setState(() {
        _checkedInToday = false;
        _todayWorkoutTitle = null;
      });
    }
  }

  Future<List<String>> _uploadImages({
    required String userId,
    required List<XFile> images,
  }) async {
    if (images.isEmpty) return [];
    final imageUrls = <String>[];

    for (int i = 0; i < images.length; i++) {
      final ref = FirebaseStorage.instance.ref().child(
        'completed_workouts/$userId/images/${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
      );
      await ref.putFile(
        File(images[i].path),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      imageUrls.add(await ref.getDownloadURL());
    }

    return imageUrls;
  }

  Future<List<String>> _uploadVideos({
    required String userId,
    required List<XFile> videos,
  }) async {
    if (videos.isEmpty) return [];
    final videoUrls = <String>[];

    for (int i = 0; i < videos.length; i++) {
      final ref = FirebaseStorage.instance.ref().child(
        'completed_workouts/$userId/videos/${DateTime.now().millisecondsSinceEpoch}_$i.mp4',
      );
      await ref.putFile(
        File(videos[i].path),
        SettableMetadata(contentType: 'video/mp4'),
      );
      videoUrls.add(await ref.getDownloadURL());
    }

    return videoUrls;
  }

  Future<void> _removeTodayCheckIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final checkinDoc =
        await FirebaseFirestore.instance.collection('checkins').doc(user.uid).get();

    final data = checkinDoc.data() ?? {};
    final entries = Map<String, dynamic>.from(data['entries'] ?? {});
    final todayEntry = entries[_todayKey()];
    String? feedPostId;

    if (todayEntry is Map) {
      feedPostId = todayEntry['feedPostId']?.toString();
    }

    if (feedPostId != null && feedPostId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('feed_posts').doc(feedPostId).delete();
    }

    await FirebaseFirestore.instance.collection('checkins').doc(user.uid).set({
      'entries': {_todayKey(): FieldValue.delete()},
    }, SetOptions(merge: true));

    if (!mounted) return;
    setState(() {
      _checkedInToday = false;
      _todayWorkoutTitle = null;
    });
  }

  Future<void> _saveTodayWorkout({
    required WorkoutPost workout,
    required _CompletionResult completion,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _savingCheckIn = true);

    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      final username = (userDoc.data()?['username'] ?? 'Utilizador').toString();
      final isPrivate = userDoc.data()?['isPrivate'] == true;

      final imageUrls = await _uploadImages(userId: user.uid, images: completion.images);
      final videoUrls = await _uploadVideos(userId: user.uid, videos: completion.videos);

      String? feedPostId;

      if (completion.postToFeed) {
        final postRef = FirebaseFirestore.instance.collection('feed_posts').doc();

        await postRef.set({
          'title': workout.title,
          'userId': user.uid,
          'username': username,
          'templateId': workout.id,
          'authorIsPrivate': isPrivate,
          'exercises': workout.exercises,
          'imageUrls': imageUrls,
          'videoUrls': videoUrls,
          'totalWeight': workout.totalWeight,
          'likes': 0,
          'likedBy': [],
          'comments': 0,
          'createdAt': Timestamp.now(),
        });

        feedPostId = postRef.id;
      }

      await FirebaseFirestore.instance.collection('checkins').doc(user.uid).set({
        'entries': {
          _todayKey(): {
            'workoutId': workout.id,
            'workoutTitle': workout.title,
            'imageUrls': imageUrls,
            'videoUrls': videoUrls,
            'postedToFeed': completion.postToFeed,
            'feedPostId': feedPostId,
            'checkedAt': Timestamp.now(),
          },
        },
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        _checkedInToday = true;
        _todayWorkoutTitle = workout.title;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            completion.postToFeed
                ? 'Treino concluido e publicado'
                : 'Treino concluido sem publicar no feed',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao publicar treino: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingCheckIn = false);
    }
  }

  Future<void> _openWorkoutSelector() async {
    final selectedWorkout = await showModalBottomSheet<WorkoutPost>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _WorkoutSelectorSheet(),
    );

    if (!mounted || selectedWorkout == null) return;

    final completion = await showModalBottomSheet<_CompletionResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WorkoutCompletionSheet(workoutTitle: selectedWorkout.title),
    );

    if (!mounted || completion == null) return;

    await _saveTodayWorkout(workout: selectedWorkout, completion: completion);
  }

  Future<void> _showTodayOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Trocar treino de hoje'),
              onTap: () async {
                Navigator.pop(context);
                await _openWorkoutSelector();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Apagar treino salvo de hoje'),
              onTap: () async {
                Navigator.pop(context);
                await _removeTodayCheckIn();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Powerank'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserSearchPage()),
              );
            },
          ),
          Builder(
            builder: (context) => NotificationMenuButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _checkedInToday ? Colors.blueGrey : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  icon: _savingCheckIn
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _checkedInToday
                              ? Icons.check_circle
                              : Icons.fitness_center,
                        ),
                  label: Text(
                    _checkedInToday
                        ? 'Treino concluido hoje: ${_todayWorkoutTitle ?? ''}'
                        : 'Qual treino fez hoje?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _savingCheckIn
                      ? null
                      : (_checkedInToday ? _showTodayOptions : _openWorkoutSelector),
                ),
                if (!_checkedInToday) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateWorkoutPage()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nao tenho treino, criar agora'),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: currentUser == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .snapshots(),
              builder: (context, userSnapshot) {
                final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                final following = Set<String>.from(userData?['following'] ?? []);

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('feed_posts').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'Nenhum treino postado no feed ainda',
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs.toList()
                      ..sort((a, b) {
                        final aTs = a.data()['createdAt'] as Timestamp?;
                        final bTs = b.data()['createdAt'] as Timestamp?;
                        return (bTs?.millisecondsSinceEpoch ?? 0)
                            .compareTo(aTs?.millisecondsSinceEpoch ?? 0);
                      });
                    final posts = docs.map(_postFromDoc).toList();

                    final followingPosts = <WorkoutPost>[];
                    final suggestedPosts = <WorkoutPost>[];

                    for (final post in posts) {
                      final raw = docs.firstWhere((doc) => doc.id == post.id).data();
                      final isPrivate = raw['authorIsPrivate'] == true;
                      final isMine = post.userId == currentUser?.uid;
                      final isFollowing = following.contains(post.userId);

                      if (isMine || isFollowing) {
                        followingPosts.add(post);
                      } else if (!isPrivate) {
                        suggestedPosts.add(post);
                      }
                    }

                    final ordered = [...followingPosts, ...suggestedPosts];

                    if (ordered.isEmpty) {
                      return Center(
                        child: Text(
                          'Sem posts visiveis no teu feed',
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }

                    bool suggestedHeaderShown = false;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: ordered.length,
                      itemBuilder: (context, index) {
                        final post = ordered[index];
                        final isSuggested = !following.contains(post.userId) &&
                            post.userId != currentUser?.uid;

                        final showSuggestedHeader =
                            isSuggested && !suggestedHeaderShown;

                        if (showSuggestedHeader) {
                          suggestedHeaderShown = true;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showSuggestedHeader)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Sugeridos',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            WorkoutPostCard(post: post),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateWorkoutPage()),
          );
          await _loadTodayCheckIn();
        },
      ),
    );
  }
}

class _CompletionResult {
  final bool postToFeed;
  final List<XFile> images;
  final List<XFile> videos;

  _CompletionResult({
    required this.postToFeed,
    required this.images,
    required this.videos,
  });
}

class _WorkoutSelectorSheet extends StatelessWidget {
  const _WorkoutSelectorSheet();

  WorkoutPost _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return WorkoutPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      user: (data['username'] ?? 'Utilizador').toString(),
      time: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate().toString()
          : 'agora',
      title: data['title'] ?? '',
      exercises: List<Map<String, dynamic>>.from(
        (data['exercises'] ?? []).map(
          (e) => e is Map<String, dynamic>
              ? e
              : Map<String, dynamic>.from(e as Map),
        ),
      ),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      videoUrls: List<String>.from(data['videoUrls'] ?? []),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      commentsList: [],
      likedBy: List<String>.from(data['likedBy'] ?? []),
      totalWeight: (data['totalWeight'] ?? 0).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SizedBox(
          height: 420,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Qual treino fez hoje?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Escolhe um treino que ja criaste.'),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: user == null
                      ? null
                      : FirebaseFirestore.instance
                          .collection('workout_templates')
                          .where('userId', isEqualTo: user.uid)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('Ainda nao tens nenhum treino criado.'),
                      );
                    }

                    final workouts = docs.map(_fromDoc).toList();

                    return ListView.separated(
                      itemCount: workouts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final workout = workouts[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.fitness_center),
                            title: Text(workout.title),
                            subtitle: Text('${workout.exercises.length} exercicios'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.pop(context, workout),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutCompletionSheet extends StatefulWidget {
  final String workoutTitle;

  const _WorkoutCompletionSheet({required this.workoutTitle});

  @override
  State<_WorkoutCompletionSheet> createState() => _WorkoutCompletionSheetState();
}

class _WorkoutCompletionSheetState extends State<_WorkoutCompletionSheet> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  final List<XFile> _videos = [];
  bool _postToFeed = false;

  Future<void> _pickFromGallery() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isEmpty) return;
    setState(() => _images.addAll(images));
  }

  Future<void> _pickVideo() async {
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;
    setState(() => _videos.add(video));
  }

  Future<void> _pickVideoCamera() async {
    final video = await _picker.pickVideo(source: ImageSource.camera);
    if (video == null) return;
    setState(() => _videos.add(video));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Concluir treino: ${widget.workoutTitle}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Podes adicionar imagens e videos.'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Imagens'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.video_library),
                      label: const Text('Video'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickVideoCamera,
                      icon: const Icon(Icons.videocam),
                      label: const Text('Gravar video'),
                    ),
                  ),
                ],
              ),
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Imagens escolhidas'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(_images[index].path),
                        width: 90,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ],
              if (_videos.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('${_videos.length} video(s) selecionado(s)'),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                value: _postToFeed,
                contentPadding: EdgeInsets.zero,
                title: const Text('Postar este treino no feed'),
                subtitle: const Text(
                  'Se estiver desligado, fica apenas como concluido.',
                ),
                onChanged: (value) {
                  setState(() => _postToFeed = value);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _CompletionResult(
                        postToFeed: _postToFeed,
                        images: _images,
                        videos: _videos,
                      ),
                    );
                  },
                  child: const Text('Confirmar treino concluido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
