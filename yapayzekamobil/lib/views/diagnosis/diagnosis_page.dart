import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yapayzekamobil/base_components/border_radius.dart';
import 'package:yapayzekamobil/base_components/colors.dart';
import 'package:yapayzekamobil/base_components/icons.dart';
import 'package:yapayzekamobil/base_components/paddings.dart';
import 'package:yapayzekamobil/base_components/text_styles.dart';
import 'package:yapayzekamobil/providers/diagnosis/diagnosis_provider.dart';

class DiagnosisPage extends ConsumerStatefulWidget {
  const DiagnosisPage({super.key});

  @override
  ConsumerState<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends ConsumerState<DiagnosisPage> {
  File? _imageFile;
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(diagnosisProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  dynamic parseJsonLeniently(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      String cleanedJson = jsonString
          .replaceAll(RegExp(r'[\u0000-\u001F]'), '')
          .replaceAll(',}', '}')
          .replaceAll(',]', ']');

      try {
        return jsonDecode(cleanedJson);
      } catch (e) {
        throw Exception('Failed to parse JSON even after cleaning: $e');
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  void _createDiagnosis() {
    if (_imageFile == null) {
      _showErrorSnackBar('Please select an image first');
      return;
    }

    ref.read(diagnosisProvider.notifier).createDiagnosis(_imageFile!,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diagnosisState = ref.watch(diagnosisProvider);

    ref.listen<DiagnosisState>(diagnosisProvider, (previous, next) {
      if (next.currentDiagnosis != null && previous?.currentDiagnosis == null) {
        Navigator.of(context).pushNamed(
          '/doctors',
          arguments: {
            'diagnosis': next.currentDiagnosis!,
            'recommendedDoctors': next.recommendedDoctors,
          },
        );
      }

      if (next.errorMessage != null) {
        _showErrorSnackBar(next.errorMessage!);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        ref.read(diagnosisProvider.notifier).resetState();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Teşhiş Oluştur'),
          leading: IconButton(
            splashColor: AppColors.transparent,
            highlightColor: AppColors.transparent,
            icon: SvgPicture.asset(
              AppIcons.leftArrowWhite,
            ),
            onPressed: () {
              ref.read(diagnosisProvider.notifier).resetState();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: AppPaddings.componentPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () => _showImagePickerDialog(context),
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppBorderRadius.radius8,
                    border: Border.all(
                        color: AppColors.borderColor, width: 2
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Resim Seç',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: AppPaddings.vertical,
                child: TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Not (Opsiyonel)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),

              ElevatedButton(
                onPressed: diagnosisState.isLoading ? null : _createDiagnosis,
                child: diagnosisState.isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : Text('Teşhis Oluştur', style: poppins.w600.f15.white,),
              ),

              if (diagnosisState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    diagnosisState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox.shrink(),
                    Text(
                      'Resim Seç',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: SvgPicture.asset(AppIcons.closeBlack),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImagePickerOption(
                      context,
                      icon: Icons.photo_library,
                      title: 'Galeri',
                      onTap: () {
                        _pickImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.mainColor,
              size: 30,
            ),
          ),
          Padding(
            padding: AppPaddings.onlyTopPaddingSmall,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
