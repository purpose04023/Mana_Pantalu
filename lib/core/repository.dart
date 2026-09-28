import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mana_pantalu/app/env.dart';

class Crop {
  final String id;
  final String nameTe;
  final String nameEn;
  final String descriptionTe;
  final String descriptionEn;

  Crop({
    required this.id,
    required this.nameTe,
    required this.nameEn,
    required this.descriptionTe,
    required this.descriptionEn,
  });
}

class CropStage {
  final String cropId;
  final int stageOrder;
  final String nameTe;
  final String nameEn;
  final int startDay;
  final int endDay;
  final String careActionTe;
  final String careActionEn;

  CropStage({
    required this.cropId,
    required this.stageOrder,
    required this.nameTe,
    required this.nameEn,
    required this.startDay,
    required this.endDay,
    required this.careActionTe,
    required this.careActionEn,
  });
}

class Disease {
  final String id;
  final String cropId;
  final String nameTe;
  final String nameEn;
  final List<String> symptomsTe;
  final List<String> symptomsEn;
  final List<String> causesTe;
  final List<String> causesEn;
  final List<String> preventionTe;
  final List<String> preventionEn;
  final List<String> careTe;
  final List<String> careEn;
  final List<String> treatmentTe;
  final List<String> treatmentEn;

  Disease({
    required this.id,
    required this.cropId,
    required this.nameTe,
    required this.nameEn,
    required this.symptomsTe,
    required this.symptomsEn,
    required this.causesTe,
    required this.causesEn,
    required this.preventionTe,
    required this.preventionEn,
    required this.careTe,
    required this.careEn,
    required this.treatmentTe,
    required this.treatmentEn,
  });
}

class Tip {
  final String id;
  final String category;
  final String titleTe;
  final String titleEn;
  final String bodyTe;
  final String bodyEn;

  Tip({
    required this.id,
    required this.category,
    required this.titleTe,
    required this.titleEn,
    required this.bodyTe,
    required this.bodyEn,
  });
}

class UserCrop {
  final String id;
  final String cropId;
  final DateTime sowingDate;
  final double fieldSizeAcres;
  final String locationText;

  UserCrop({
    required this.id,
    required this.cropId,
    required this.sowingDate,
    required this.fieldSizeAcres,
    required this.locationText,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'cropId': cropId,
        'sowingDate': sowingDate.toIso8601String(),
        'fieldSizeAcres': fieldSizeAcres,
        'locationText': locationText,
      };

  factory UserCrop.fromMap(Map<String, dynamic> map) => UserCrop(
        id: map['id'] ?? '',
        cropId: map['cropId'] ?? 'rice',
        sowingDate: DateTime.parse(map['sowingDate']),
        fieldSizeAcres: (map['fieldSizeAcres'] as num).toDouble(),
        locationText: map['locationText'] ?? '',
      );
}

class ScanResult {
  final String scanId;
  final String status; // 'done', 'low_confidence', 'failed'
  final String? cropId;
  final String? diseaseId;
  final double confidence;
  final String imageQuality;
  final DateTime createdAt;

  ScanResult({
    required this.scanId,
    required this.status,
    this.cropId,
    this.diseaseId,
    required this.confidence,
    required this.imageQuality,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'scanId': scanId,
        'status': status,
        'cropId': cropId,
        'diseaseId': diseaseId,
        'confidence': confidence,
        'imageQuality': imageQuality,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ScanResult.fromMap(Map<String, dynamic> map) => ScanResult(
        scanId: map['scanId'] ?? '',
        status: map['status'] ?? 'done',
        cropId: map['cropId'],
        diseaseId: map['diseaseId'],
        confidence: (map['confidence'] as num).toDouble(),
        imageQuality: map['imageQuality'] ?? 'good',
        createdAt: DateTime.parse(map['createdAt']),
      );
}

class AppRepository {
  static final AppRepository instance = AppRepository._internal();
  AppRepository._internal();

  final List<UserCrop> _userCrops = [
    UserCrop(
      id: "uc1",
      cropId: "rice",
      sowingDate: DateTime.now().subtract(const Duration(days: 40)),
      fieldSizeAcres: 2.5,
      locationText: "Guntur",
    ),
  ];

  final List<ScanResult> _scanHistory = [
    ScanResult(
      scanId: "s1",
      status: "done",
      cropId: "rice",
      diseaseId: "rice_brown_spot",
      confidence: 0.92,
      imageQuality: "good",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    )
  ];

  final Set<String> _savedTipIds = {};

  final List<Crop> crops = [
    Crop(id: 'rice', nameTe: 'వరి', nameEn: 'Rice (Paddy)', descriptionTe: 'ఖరీఫ్, రబీ రెండింటిలో సాగు చేసే ప్రధాన పంట.', descriptionEn: 'Main staple crop grown in kharif and rabi.'),
    Crop(id: 'cotton', nameTe: 'పత్తి', nameEn: 'Cotton', descriptionTe: 'నల్లరేగడి నేలల్లో బాగా పండుతుంది.', descriptionEn: 'Grows well in black soils.'),
    Crop(id: 'chilli', nameTe: 'మిరప', nameEn: 'Chilli', descriptionTe: 'ఆంధ్రప్రదేశ్‌లో ముఖ్యమైన వాణిజ్య పంట.', descriptionEn: 'Important commercial crop in Andhra Pradesh.'),
    Crop(id: 'groundnut', nameTe: 'వేరుశనగ', nameEn: 'Groundnut', descriptionTe: 'ఎర్ర నేలల్లో సాగు చేస్తారు.', descriptionEn: 'Grown mostly in red soils.'),
    Crop(id: 'maize', nameTe: 'మొక్కజొన్న', nameEn: 'Maize', descriptionTe: 'ఖరీఫ్, రబీ రెండింటిలో సాగు.', descriptionEn: 'Grown in kharif and rabi.'),
    Crop(id: 'tomato', nameTe: 'టమాటా', nameEn: 'Tomato', descriptionTe: 'కూరగాయల పంట.', descriptionEn: 'Vegetable crop.'),
    Crop(id: 'banana', nameTe: 'అరటి', nameEn: 'Banana', descriptionTe: 'దీర్ఘకాలిక తోట పంట.', descriptionEn: 'Long-duration plantation crop.'),
    Crop(id: 'sugarcane', nameTe: 'చెరకు', nameEn: 'Sugarcane', descriptionTe: 'దీర్ఘకాలిక వాణిజ్య పంట.', descriptionEn: 'Long-duration commercial crop.'),
  ];

  final Map<String, List<CropStage>> stages = {
    'rice': [
      CropStage(cropId: 'rice', stageOrder: 1, nameTe: 'నారుమడి', nameEn: 'Nursery', startDay: 0, endDay: 25, careActionTe: 'నారుమడిలో నీరు తగినంత ఉంచండి.', careActionEn: 'Keep enough water in the nursery.'),
      CropStage(cropId: 'rice', stageOrder: 2, nameTe: 'పిలకలు వేసే దశ', nameEn: 'Tillering', startDay: 26, endDay: 55, careActionTe: 'మొదటి దఫా ఎరువు వేసే సమయం.', careActionEn: 'Time for the first fertilizer dose.'),
      CropStage(cropId: 'rice', stageOrder: 3, nameTe: 'ఈనిక దశ', nameEn: 'Panicle initiation', startDay: 56, endDay: 85, careActionTe: 'నీరు నిలవ ఉండేలా చూసుకోండి.', careActionEn: 'Maintain standing water.'),
      CropStage(cropId: 'rice', stageOrder: 4, nameTe: 'గింజ పాలు పోసుకునే దశ', nameEn: 'Grain filling', startDay: 86, endDay: 110, careActionTe: 'తెగుళ్ల కోసం పొలం పరిశీలించండి.', careActionEn: 'Inspect the field for pests and disease.'),
      CropStage(cropId: 'rice', stageOrder: 5, nameTe: 'కోత', nameEn: 'Harvest', startDay: 111, endDay: 125, careActionTe: 'గింజలు గట్టిపడ్డాక కోత కోయండి.', careActionEn: 'Harvest when grains are firm.'),
    ]
  };

  final Map<String, Disease> diseases = {
    'rice_brown_spot': Disease(
      id: 'rice_brown_spot',
      cropId: 'rice',
      nameTe: 'ఆకుమచ్చ వ్యాధి',
      nameEn: 'Brown spot',
      symptomsTe: ['ఆకులపై గోధుమ రంగు మచ్చలు కనిపిస్తాయి.'],
      symptomsEn: ['Brown spots appear on leaves.'],
      causesTe: ['పోషకాల లోపం, తేమ ఎక్కువగా ఉండటం.'],
      causesEn: ['Nutrient deficiency, high humidity.'],
      preventionTe: ['ఆరోగ్యమైన విత్తనం వాడండి.'],
      preventionEn: ['Use healthy seed.'],
      careTe: ['పొలంలో నీరు సరిగా నిర్వహించండి.'],
      careEn: ['Manage field water properly.'],
      treatmentTe: ['సరైన మందు, మోతాదు కోసం వ్యవసాయ అధికారిని సంప్రదించండి.'],
      treatmentEn: ['Consult your agriculture officer for the right product and dose.'],
    ),
    'rice_blast': Disease(
      id: 'rice_blast',
      cropId: 'rice',
      nameTe: 'అగ్గి తెగులు',
      nameEn: 'Blast',
      symptomsTe: ['ఆకులపై కంటి ఆకారపు మచ్చలు.'],
      symptomsEn: ['Eye-shaped spots on leaves.'],
      causesTe: ['చల్లని, తేమ వాతావరణం.'],
      causesEn: ['Cool, humid weather.'],
      preventionTe: ['ఎక్కువ నత్రజని వేయవద్దు.'],
      preventionEn: ['Avoid excess nitrogen.'],
      careTe: ['పొలాన్ని రోజూ పరిశీలించండి.'],
      careEn: ['Inspect the field daily.'],
      treatmentTe: ['సరైన మందు, మోతాదు కోసం వ్యవసాయ అధికారిని సంప్రదించండి.'],
      treatmentEn: ['Consult your agriculture officer for the right product and dose.'],
    ),
    'cotton_leaf_curl': Disease(
      id: 'cotton_leaf_curl',
      cropId: 'cotton',
      nameTe: 'ఆకు ముడత',
      nameEn: 'Leaf curl',
      symptomsTe: ['ఆకులు పైకి ముడుచుకుంటాయి.'],
      symptomsEn: ['Leaves curl upward.'],
      causesTe: ['తెల్లదోమ ద్వారా వ్యాపిస్తుంది.'],
      causesEn: ['Spread by whitefly.'],
      preventionTe: ['పొలంలో కలుపు తీసేయండి.'],
      preventionEn: ['Remove weeds.'],
      careTe: ['ప్రభావిత మొక్కలను గమనించండి.'],
      careEn: ['Watch affected plants.'],
      treatmentTe: ['సరైన మందు, మోతాదు కోసం వ్యవసాయ అధికారిని సంప్రదించండి.'],
      treatmentEn: ['Consult your agriculture officer for the right product and dose.'],
    ),
    'tomato_early_blight': Disease(
      id: 'tomato_early_blight',
      cropId: 'tomato',
      nameTe: 'ఆకు మచ్చ తెగులు',
      nameEn: 'Early blight',
      symptomsTe: ['ఆకులపై వలయాకార గోధుమ మచ్చలు.'],
      symptomsEn: ['Concentric brown rings on leaves.'],
      causesTe: ['తేమ, పాత ఆకులు.'],
      causesEn: ['Humidity, older leaves.'],
      preventionTe: ['కింది ఆకులు తీసేయండి.'],
      preventionEn: ['Remove lower leaves.'],
      careTe: ['మొక్కల మధ్య గాలి ఆడేలా చూడండి.'],
      careEn: ['Keep good airflow between plants.'],
      treatmentTe: ['సరైన మందు, మోతాదు కోసం వ్యవసాయ అధికారిని సంప్రదించండి.'],
      treatmentEn: ['Consult your agriculture officer for the right product and dose.'],
    ),
  };

  final List<Tip> tips = [
    Tip(id: 't1', category: 'crop_care', titleTe: 'ఈ రోజు పంట సూచన', titleEn: 'Today\'s crop-care tip', bodyTe: 'ఉదయం పొలాన్ని ఒకసారి చుట్టి చూడండి.', bodyEn: 'Walk your field once in the morning.'),
    Tip(id: 't2', category: 'fertilizer', titleTe: 'దశ ప్రకారం ఎరువు', titleEn: 'Fertilizer by stage', bodyTe: 'పిలకల దశలో ఎరువు సమయం చూసుకోండి.', bodyEn: 'Check fertilizer timing at tillering.'),
    Tip(id: 't3', category: 'irrigation_weather', titleTe: 'నీరు + వాతావరణం', titleEn: 'Irrigation + weather', bodyTe: 'వర్షం వస్తుందని అంచనా ఉంటే నీరు పెట్టడం ఆపండి.', bodyEn: 'If rain is forecast, hold irrigation.'),
    Tip(id: 't4', category: 'pest_prevention', titleTe: 'పురుగుల నివారణ', titleEn: 'Pest prevention', bodyTe: 'ఆకుల కింద భాగం చూడండి, పురుగులు ఉంటాయి.', bodyEn: 'Check the underside of leaves for pests.'),
  ];

  List<UserCrop> getUserCrops() => _userCrops;

  void addUserCrop(UserCrop crop) {
    _userCrops.add(crop);
    _syncUserCropToFirestore(crop);
  }

  List<ScanResult> getScanHistory() => _scanHistory;

  ScanResult? getScan(String scanId) {
    try {
      return _scanHistory.firstWhere((s) => s.scanId == scanId);
    } catch (_) {
      return _scanHistory.isNotEmpty ? _scanHistory.first : null;
    }
  }

  Set<String> getSavedTips() => _savedTipIds;

  void toggleSaveTip(String tipId) {
    if (_savedTipIds.contains(tipId)) {
      _savedTipIds.remove(tipId);
    } else {
      _savedTipIds.add(tipId);
    }
  }

  CropStage getCurrentStageFor(UserCrop userCrop) {
    final daysSinceSowing = DateTime.now().difference(userCrop.sowingDate).inDays;
    final cropStages = stages[userCrop.cropId] ?? [];
    for (var stage in cropStages) {
      if (daysSinceSowing >= stage.startDay && daysSinceSowing <= stage.endDay) {
        return stage;
      }
    }
    return cropStages.isNotEmpty
        ? cropStages.last
        : CropStage(
            cropId: userCrop.cropId,
            stageOrder: 1,
            nameTe: 'ఎదుగుదల దశ',
            nameEn: 'Growth Stage',
            startDay: 0,
            endDay: 100,
            careActionTe: 'పంటను రోజూ గమనించండి.',
            careActionEn: 'Observe the crop daily.',
          );
  }

  Future<void> _syncUserCropToFirestore(UserCrop crop) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('user_crops')
            .doc(crop.id)
            .set(crop.toMap());
      }
    } catch (_) {}
  }

  Future<void> _syncScanToFirestoreAndStorage(ScanResult scan, File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('scans/${user.uid}/${scan.scanId}.jpg');
        await storageRef.putFile(imageFile);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('scans')
            .doc(scan.scanId)
            .set(scan.toMap());
      }
    } catch (_) {}
  }

  Future<ScanResult> diagnoseImage(File imageFile) async {
    final scanId = "scan_${DateTime.now().millisecondsSinceEpoch}";

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: Env.geminiApiKey,
      );

      final imageBytes = await imageFile.readAsBytes();
      final prompt = TextPart('''
You are a plant-health image classifier for an agriculture app used by Indian farmers.
Look at the photo and return ONLY JSON matching this exact structure:
{"crop_id": "rice|cotton|chilli|groundnut|maize|tomato|banana|sugarcane|unknown", "disease_id": "rice_brown_spot|rice_blast|cotton_leaf_curl|tomato_early_blight|healthy|unknown", "confidence": 0.85, "image_quality": "good|poor"}

Supported diseases:
- rice_brown_spot (crop_id: rice)
- rice_blast (crop_id: rice)
- cotton_leaf_curl (crop_id: cotton)
- tomato_early_blight (crop_id: tomato)
- healthy (no disease)
- unknown (blurry, far away, not a supported leaf or uncertain)
''');
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final text = response.text ?? '';
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);

      if (jsonMatch != null) {
        final parsed = json.decode(jsonMatch.group(0)!);
        final cropId = parsed['crop_id'] as String?;
        final diseaseId = parsed['disease_id'] as String?;
        final confidence = (parsed['confidence'] as num?)?.toDouble() ?? 0.5;
        final quality = (parsed['image_quality'] as String?) ?? 'good';

        if (confidence < 0.60 ||
            quality == 'poor' ||
            diseaseId == 'unknown' ||
            cropId == 'unknown') {
          final res = ScanResult(
            scanId: scanId,
            status: 'low_confidence',
            cropId: cropId != 'unknown' ? cropId : null,
            diseaseId: null,
            confidence: confidence,
            imageQuality: quality,
            createdAt: DateTime.now(),
          );
          _scanHistory.insert(0, res);
          await _syncScanToFirestoreAndStorage(res, imageFile);
          return res;
        }

        final validCropId = crops.any((c) => c.id == cropId) ? cropId : 'rice';
        final validDiseaseId = diseases.containsKey(diseaseId) ? diseaseId : null;

        final res = ScanResult(
          scanId: scanId,
          status: validDiseaseId != null ? 'done' : 'low_confidence',
          cropId: validCropId,
          diseaseId: validDiseaseId,
          confidence: confidence,
          imageQuality: quality,
          createdAt: DateTime.now(),
        );
        _scanHistory.insert(0, res);
        await _syncScanToFirestoreAndStorage(res, imageFile);
        return res;
      }
    } catch (_) {}

    // Fallback if network/AI is unavailable or fails to respond cleanly
    final res = ScanResult(
      scanId: scanId,
      status: 'low_confidence',
      cropId: null,
      diseaseId: null,
      confidence: 0.45,
      imageQuality: 'poor',
      createdAt: DateTime.now(),
    );
    _scanHistory.insert(0, res);
    await _syncScanToFirestoreAndStorage(res, imageFile);
    return res;
  }
}

final repositoryProvider = Provider<AppRepository>((ref) => AppRepository.instance);
