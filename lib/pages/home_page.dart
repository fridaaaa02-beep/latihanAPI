import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import 'form_page.dart';
class HomePage extends StatefulWidget {
 const HomePage({super.key});
 @override
 State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
 final ApiService apiService = ApiService();
 late Future<List<Post>> futurePosts;
 @override
 void initState() {
 super.initState();
 futurePosts = apiService.getPosts();
 }
 void refreshData() {
 setState(() {
 futurePosts = apiService.getPosts();
 });
 } Future<void> deleteData(int id) async {
 try {
 await apiService.deletePost(id);
 if (!mounted) return;
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Data berhasil dihapus')),
 );
 refreshData();
 } catch (e) {
 if (!mounted) return;
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Error: $e')),
 );
 }
 }
 void confirmDelete(int id) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Hapus Data'),
 content: const Text(
 'Apakah Anda yakin ingin menghapus data ini?',
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Batal'),
 ),
 ElevatedButton(
 onPressed: () {
 Navigator.pop(context);
 deleteData(id);
 },
 child: const Text('Hapus'),
 ),
 ],
 ),
 );
 }
 Future<void> openForm({Post? post}) async {
 final result = await Navigator.push(
 context,
 MaterialPageRoute(
 builder: (context) => FormPage(post: post),
 ),
 );
 if (result == true) refreshData();
 }
 @override
 Widget build(BuildContext context) {
 return Scaffold(
 appBar: AppBar(
 title: const Text('REST API CRUD'),
 actions: [
 IconButton(
 onPressed: refreshData,
 icon: const Icon(Icons.refresh),
 ),
 ],
 ),
 floatingActionButton: FloatingActionButton(
 onPressed: () => openForm(),
 child: const Icon(Icons.add),
 ),
 body: FutureBuilder<List<Post>>(
 future: futurePosts,
 builder: (context, snapshot) {
 if (snapshot.connectionState == ConnectionState.waiting) {
 return const Center(
 child: CircularProgressIndicator(),
 );
 }
 if (snapshot.hasError) {
 return Center(
 child: Column( mainAxisAlignment: MainAxisAlignment.center,
 children: [
 const Icon(Icons.error, size: 60),
 const SizedBox(height: 10),
 Text(
 'Terjadi kesalahan:\n${snapshot.error}',
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 10),
 ElevatedButton(
 onPressed: refreshData,
 child: const Text('Coba Lagi'),
 ),
 ],
 ),
 );
 }
 if (!snapshot.hasData || snapshot.data!.isEmpty) {
 return const Center(child: Text('Data kosong'));
 }
 final posts = snapshot.data!;
 return RefreshIndicator(
 onRefresh: () async => refreshData(),
 child: ListView.builder(
 itemCount: posts.length,
 itemBuilder: (context, index) {
 final post = posts[index];
 return Card(
 margin: const EdgeInsets.symmetric(
 horizontal: 12,
 vertical: 6,
 ),
 child: ListTile(
 leading: CircleAvatar(
 child: Text('${post.id}'),
 ),
 title: Text(
 post.title,
 maxLines: 1,
 overflow: TextOverflow.ellipsis,
 ),
 subtitle: Text(
 post.body,
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 trailing: PopupMenuButton(
 onSelected: (value) {
 if (value == 'edit') {
 openForm(post: post);
 }
 if (value == 'delete') {
 confirmDelete(post.id);
 }
 },
 itemBuilder: (context) => const [
 PopupMenuItem(
 value: 'edit',
 child: Text('Edit'),
 ),
 PopupMenuItem(
 value: 'delete',
 child: Text('Hapus'),
 ),
 ],
 ),
 ),
 );
 },
 ),
 );
 },
 ),
 );
 }
}