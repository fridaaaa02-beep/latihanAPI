import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  // Ganti dengan URL dan ANON KEY Supabase Anda
  static const String baseUrl = 'https://uxrqbbpvawxopmrvkcgn.supabase.co/rest/v1';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV4cnFiYnB2YXd4b3BtcnZrY2duIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE0ODU5MzIsImV4cCI6MjEwNzA2MTkzMn0.R0fIHM3G2m-6cfkDMz_O1td0UxloyQSFoREjLlmgpoI';

  // Header standar untuk komunikasi dengan Supabase REST API
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
      };

  // 1. Get All Posts
  Future<List<Post>> getPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts?select=*'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data. Status: ${response.statusCode}');
    }
  }

  // 2. Get Single Post by ID
  Future<Post> getPost(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts?id=eq.$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return Post.fromJson(data.first);
      }
      throw Exception('Data tidak ditemukan');
    } else {
      throw Exception('Gagal mengambil detail data');
    }
  }

  // 3. Create Post
  Future<Post> createPost({
    required String title,
    required String body,
    required int userId,
  }) async {
    final customHeaders = Map<String, String>.from(headers)
      ..['Prefer'] = 'return=representation'; // Agar Supabase mengembalikan data yang baru di-insert

    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: customHeaders,
      body: jsonEncode({
        'title': title,
        'body': body,
        'userId': userId,
      }),
    );

    if (response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return Post.fromJson(data.first);
    } else {
      throw Exception('Gagal menambahkan data: ${response.body}');
    }
  }

  // 4. Update Post
  Future<Post> updatePost({
    required int id,
    required String title,
    required String body,
    required int userId,
  }) async {
    final customHeaders = Map<String, String>.from(headers)
      ..['Prefer'] = 'return=representation';

    final response = await http.patch( // Menggunakan PATCH untuk update di Supabase
      Uri.parse('$baseUrl/posts?id=eq.$id'),
      headers: customHeaders,
      body: jsonEncode({
        'title': title,
        'body': body,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return Post.fromJson(data.first);
    } else {
      throw Exception('Gagal mengubah data');
    }
  }

  // 5. Delete Post
  Future<void> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts?id=eq.$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus data');
    }
  }
}