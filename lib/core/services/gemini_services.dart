import 'dart:convert';
import 'dart:io';
import 'package:fidyah_ai/core/constants/api_key.dart';
import 'package:fidyah_ai/core/constants/prompt.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServices {
  late final GenerativeModel _model;
  late ChatSession _chatSession;
  bool isMockMode = true; // Default to true for demo safety

  GeminiServices() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      systemInstruction: Content.system(prompt),
    );
    _chatSession = _model.startChat();
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ]);
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Respons kosong dari AI');
      }
      debugPrint('[Gemini] Raw response: ${response.text}');
      return jsonDecode(response.text!);
    } on FormatException catch (e) {
      throw Exception('Format JSON tidak valid: $e');
    } catch (e) {
      throw Exception('Gagal menganalisis gambar: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessage(String text) async {
    if (isMockMode) {
      debugPrint('[Gemini] Running in MOCK MODE');
      return _getMockResponse(text);
    }
    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Menerima respons kosong dari AI');
      }

      // Pastikan membersihkan blok markdown JSON bila ada
      String cleanedText = responseText.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
        if (cleanedText.endsWith('```')) {
          cleanedText = cleanedText.substring(0, cleanedText.length - 3);
        }
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
        if (cleanedText.endsWith('```')) {
          cleanedText = cleanedText.substring(0, cleanedText.length - 3);
        }
      }

      return jsonDecode(cleanedText.trim());
    } catch (e) {
      throw Exception('Gagal memproses respons dari Gemini: $e');
    }
  }

  /// Memulai sesi percakapan baru atau memuat riwayat percakapan lama
  void startNewSession({List<Content>? history}) {
    _chatSession = _model.startChat(history: history);
  }

  /// Generate judul percakapan secara otomatis dengan model Gemini terpisah
  Future<String> generateChatTitle(String initialMessage) async {
    try {
      final titleModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );
      final promptText =
          'Buatkan judul singkat (maksimal 3-5 kata) untuk percakapan fidyah yang diawali dengan pesan berikut: "$initialMessage". Hanya kembalikan teks judul saja tanpa embel-embel apapun.';
      final response = await titleModel.generateContent([
        Content.text(promptText),
      ]);
      String title = response.text?.trim() ?? 'Konsultasi Fidyah';
      // Clean up quotes if any
      if (title.startsWith('"') && title.endsWith('"') && title.length > 2) {
        title = title.substring(1, title.length - 1);
      }
      return title;
    } catch (e) {
      debugPrint('Gagal generate title: $e');
      return 'Konsultasi Fidyah';
    }
  }

  /// Hardcoded response for Mock Mode
  Map<String, dynamic> _getMockResponse(String userText) {
    return {
      "response": {
        "salam": "Assalamu'alaikum Warahmatullahi Wabarakatuh.",
        "topik": "Uzur Syar'i (Simulasi)",
        "kategori": "Fidyah",
        "jawaban": {
          "penjelasan":
              "Berdasarkan keterangan Anda: \"$userText\", ini adalah simulasi jawaban fidyah. Dalam kondisi nyata, fidyah wajib dibayarkan jika seseorang meninggalkan puasa karena alasan yang dibenarkan syariat (seperti sakit yang tidak ada harapan sembuh, tua renta, atau ibu hamil/menyusui yang mengkhawatirkan bayi) dan tidak mampu mengqadhanya.",
          "perhitungan_fidyah": {
            "berlaku": true,
            "jumlah_hari": 7,
            "tarif_per_hari": 60000,
            "total_fidyah_rupiah": 420000,
            "setara_beras_kg": 1.5,
            "edukasi_perbandingan":
                "Nilai ini setara dengan memberi makan satu orang miskin per hari sebanyak 1 mud (±0.75kg - 1.5kg beras).",
          },
        },
        "meta": {
          "status": "success",
          "model": "mock-mode-fidyah-ai",
          "timestamp": DateTime.now().toIso8601String(),
        },
        "quick_replies": [
          "Berapa takaran berasnya?",
          "Siapa yang berhak menerima?",
          "Bagaimana cara bayarnya?",
        ],
        "penutup":
            "Semoga Allah menerima amal ibadah kita. Ada lagi yang ingin Anda tanyakan?",
      },
    };
  }
}
