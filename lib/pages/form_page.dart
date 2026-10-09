import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
class FormPage extends StatefulWidget {
 final Post? post;
 const FormPage({
 super.key,
 this.post,
 });
 @override
 State<FormPage> createState() => _FormPageState();
}
class _FormPageState extends State<FormPage> {
 final ApiService apiService = ApiService();
 final titleController = TextEditingController();
 final bodyController = TextEditingController();
 final userIdController = TextEditingController();
 bool isLoading = false;
 bool get isEdit => widget.post != null;
 @override
 void initState() {
 super.initState();
 if (isEdit) {
 titleController.text = widget.post!.title;
 bodyController.text = widget.post!.body;
 userIdController.text = widget.post!.userId.toString();
 } else {
 userIdController.text = '1';
 }
 }
 @override
 void dispose() {
 titleController.dispose();
 bodyController.dispose();
 userIdController.dispose();
 super.dispose();
 }
 Future<void> saveData() async {
 if (titleController.text.isEmpty ||
 bodyController.text.isEmpty ||
 userIdController.text.isEmpty) {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Semua field harus diisi')),
 );
 return;
 }
 setState(() => isLoading = true);
 try {
 if (isEdit) {
 await apiService.updatePost(
 id: widget.post!.id,
 title: titleController.text,
 body: bodyController.text,
 userId: int.parse(userIdController.text),
 );
 } else {
 await apiService.createPost(
 title: titleController.text,
 body: bodyController.text,
 userId: int.parse(userIdController.text),
 );
 }
 if (!mounted) return;
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(
 isEdit
 ? 'Data berhasil diubah'
 : 'Data berhasil ditambahkan',
 ),
 ),
 );
 Navigator.pop(context, true);
 } catch (e) {
 if (!mounted) return;
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Terjadi kesalahan: $e')),
 );
 } finally {
 if (mounted) setState(() => isLoading = false);
 }
 }
 @override
 Widget build(BuildContext context) {
 return Scaffold(
 appBar: AppBar(
 title: Text(isEdit ? 'Edit Data' : 'Tambah Data'),
 ),
 body: SingleChildScrollView(
 padding: const EdgeInsets.all(16),
 child: Column(
 children: [
 TextField(
 controller: titleController,
 decoration: const InputDecoration(
 labelText: 'Judul',
 border: OutlineInputBorder(),
 ),
 ),
 const SizedBox(height: 16),
 TextField(
 controller: bodyController,
 maxLines: 5,
 decoration: const InputDecoration(
 labelText: 'Isi',
 border: OutlineInputBorder(),
 ),
 ),
 const SizedBox(height: 16),
 TextField(
 controller: userIdController,
 keyboardType: TextInputType.number,
 decoration: const InputDecoration(
 labelText: 'User ID',
 border: OutlineInputBorder(),
 ),
 ),
 const SizedBox(height: 24),
 SizedBox(
 width: double.infinity,
 height: 50,
 child: ElevatedButton(
 onPressed: isLoading ? null : saveData,
 child: isLoading
 ? const CircularProgressIndicator()
 : Text(isEdit ? 'UPDATE' : 'SIMPAN'),
 ),
 ),
 ],
 ),
 ),
 );
 }
}
