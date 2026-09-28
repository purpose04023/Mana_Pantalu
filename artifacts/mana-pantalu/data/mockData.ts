export type Language = 'te' | 'en';

export type Crop = {
  id: string;
  te: string;
  en: string;
  icon: string;
  color: string;
  duration: number;
  descriptionTe: string;
  descriptionEn: string;
};

export type Tip = {
  id: string;
  category: 'crop_care' | 'fertilizer' | 'irrigation' | 'pest';
  titleTe: string;
  titleEn: string;
  bodyTe: string;
  bodyEn: string;
};

export type UserCrop = {
  id: string;
  cropId: string;
  sowingDate: string;
  acres: number;
  location: string;
};

export type Scan = {
  id: string;
  uri?: string;
  date: string;
  status: 'done' | 'low';
  cropId?: string;
  diseaseId?: string;
  confidence: number;
};

export const crops: Crop[] = [
  { id: 'rice', te: 'వరి', en: 'Rice', icon: '🌾', color: '#D8EBCB', duration: 120, descriptionTe: 'ప్రధాన ఆహార పంట. ఖరీఫ్, రబీ రెండింటిలో సాగు చేస్తారు.', descriptionEn: 'A staple crop grown in both kharif and rabi seasons.' },
  { id: 'cotton', te: 'పత్తి', en: 'Cotton', icon: '✿', color: '#EEE9D9', duration: 170, descriptionTe: 'నల్లరేగడి నేలల్లో బాగా పండే వాణిజ్య పంట.', descriptionEn: 'A commercial crop that grows well in black soils.' },
  { id: 'chilli', te: 'మిరప', en: 'Chilli', icon: '◒', color: '#F8D7C8', duration: 150, descriptionTe: 'ఆంధ్రప్రదేశ్‌లో ముఖ్యమైన వాణిజ్య పంట.', descriptionEn: 'An important commercial crop in Andhra Pradesh.' },
  { id: 'groundnut', te: 'వేరుశనగ', en: 'Groundnut', icon: '◌', color: '#F4E0B9', duration: 110, descriptionTe: 'ఎర్ర నేలల్లో ఎక్కువగా సాగు చేసే పంట.', descriptionEn: 'A crop commonly grown in red soils.' },
  { id: 'maize', te: 'మొక్కజొన్న', en: 'Maize', icon: '▥', color: '#F5E4A7', duration: 110, descriptionTe: 'ఖరీఫ్, రబీ రెండింటిలో సాగు చేసే పంట.', descriptionEn: 'Grown in both kharif and rabi seasons.' },
  { id: 'tomato', te: 'టమాటా', en: 'Tomato', icon: '●', color: '#F4CBC4', duration: 120, descriptionTe: 'కూరగాయల పంట. ఆకులను తరచుగా పరిశీలించండి.', descriptionEn: 'A vegetable crop. Inspect leaves regularly.' },
  { id: 'banana', te: 'అరటి', en: 'Banana', icon: '⌁', color: '#E2EDB9', duration: 330, descriptionTe: 'దీర్ఘకాలిక తోట పంట.', descriptionEn: 'A long-duration plantation crop.' },
  { id: 'sugarcane', te: 'చెరకు', en: 'Sugarcane', icon: '▥', color: '#D5EBCF', duration: 330, descriptionTe: 'దీర్ఘకాలిక వాణిజ్య పంట.', descriptionEn: 'A long-duration commercial crop.' },
];

export const tips: Tip[] = [
  { id: 't1', category: 'crop_care', titleTe: 'ఈ రోజు పంట సూచన', titleEn: "Today's crop-care tip", bodyTe: 'ఉదయం పొలాన్ని ఒకసారి చుట్టి చూడండి. ఆకుల కింద భాగాన్ని కూడా పరిశీలించండి.', bodyEn: 'Walk your field once in the morning. Check under the leaves too.' },
  { id: 't2', category: 'fertilizer', titleTe: 'దశ ప్రకారం ఎరువు', titleEn: 'Fertilizer by stage', bodyTe: 'పంట దశను బట్టి ఎరువు వేసే సమయాన్ని పాటించండి. మోతాదు కోసం అధికారిని అడగండి.', bodyEn: 'Follow the crop stage before fertilizing. Ask an officer about the dose.' },
  { id: 't3', category: 'irrigation', titleTe: 'నీరు + వాతావరణం', titleEn: 'Irrigation + weather', bodyTe: 'వర్షం వచ్చే అవకాశం ఉంటే నీరు పెట్టడం ఆపండి. మట్టి తేమను చేతితో చూసుకోండి.', bodyEn: 'If rain is forecast, hold irrigation. Check soil moisture by hand.' },
  { id: 't4', category: 'pest', titleTe: 'పురుగుల నివారణ', titleEn: 'Pest prevention', bodyTe: 'ఆకుల కింద భాగం చూడండి. పురుగులు కనిపిస్తే త్వరగా వ్యవసాయ అధికారిని సంప్రదించండి.', bodyEn: 'Check the underside of leaves. Contact an agriculture officer early if you see pests.' },
  { id: 't5', category: 'crop_care', titleTe: 'ఒక ఆకును మాత్రమే ఫోటో తీయండి', titleEn: 'Photograph one leaf', bodyTe: 'స్పష్టమైన వెలుతురులో ఒక ఆకును దగ్గరగా ఫ్రేమ్‌లో ఉంచండి. దీంతో ఫలితం మెరుగ్గా ఉంటుంది.', bodyEn: 'Frame one leaf closely in good light for a better result.' },
];

export const disease = {
  id: 'rice_brown_spot',
  te: 'ఆకుమచ్చ వ్యాధి',
  en: 'Brown spot',
  symptomsTe: ['ఆకులపై గోధుమ రంగు మచ్చలు కనిపిస్తాయి.', 'మచ్చల మధ్య భాగం కొద్దిగా వెలుతురుగా ఉంటుంది.'],
  symptomsEn: ['Brown spots appear on leaves.', 'The center of the spots can look lighter.'],
  causesTe: ['పోషకాల లోపం లేదా తేమ ఎక్కువగా ఉండటం.', 'విత్తనం, పొలం పరిశుభ్రత సరిగా లేకపోవడం.'],
  causesEn: ['Nutrient deficiency or high humidity.', 'Poor seed and field hygiene.'],
  preventionTe: ['ఆరోగ్యమైన విత్తనం వాడండి.', 'పొలంలో నీరు సరిగా నిర్వహించండి.'],
  preventionEn: ['Use healthy seed.', 'Manage field water properly.'],
  careTe: ['ఆకులను రోజూ గమనించండి.', 'ప్రభావిత ఆకులను వేరుగా ఉంచి నిపుణుడిని అడగండి.'],
  careEn: ['Inspect leaves every day.', 'Separate affected leaves and ask an expert.'],
  treatmentTe: ['సరైన మందు, మోతాదు కోసం వ్యవసాయ అధికారిని సంప్రదించండి.'],
  treatmentEn: ['Consult your agriculture officer for the right product and dose.'],
};

export const initialCrops: UserCrop[] = [
  { id: 'uc1', cropId: 'rice', sowingDate: '2026-08-10', acres: 2.5, location: 'Guntur' },
];

export const initialScans: Scan[] = [
  { id: 's1', date: '2026-09-26T08:30:00.000Z', status: 'done', cropId: 'rice', diseaseId: disease.id, confidence: 0.92 },
];

export function cropById(id?: string) {
  return crops.find((crop) => crop.id === id);
}

export function daysSince(date: string) {
  return Math.max(0, Math.floor((Date.now() - new Date(date).getTime()) / 86400000));
}

export function stageFor(crop: UserCrop, lang: Language) {
  const days = daysSince(crop.sowingDate);
  const stages = [
    { start: 0, end: 25, te: 'నారుమడి', en: 'Nursery', careTe: 'నారుమడిలో నీరు తగినంత ఉంచండి.', careEn: 'Keep enough water in the nursery.' },
    { start: 26, end: 55, te: 'పిలకలు వేసే దశ', en: 'Tillering', careTe: 'మొదటి దఫా ఎరువు వేసే సమయం చూసుకోండి.', careEn: 'Check the timing for the first fertilizer dose.' },
    { start: 56, end: 85, te: 'ఈనిక దశ', en: 'Panicle initiation', careTe: 'నీరు నిలవ ఉండేలా చూసుకోండి.', careEn: 'Maintain standing water.' },
    { start: 86, end: 110, te: 'గింజ పాలు పోసుకునే దశ', en: 'Grain filling', careTe: 'తెగుళ్ల కోసం పొలం పరిశీలించండి.', careEn: 'Inspect the field for pests and disease.' },
    { start: 111, end: 999, te: 'కోత', en: 'Harvest', careTe: 'గింజలు గట్టిపడ్డాక కోత కోయండి.', careEn: 'Harvest when grains are firm.' },
  ];
  const stage = stages.find((item) => days >= item.start && days <= item.end) ?? stages[0];
  return { days, name: lang === 'te' ? stage.te : stage.en, care: lang === 'te' ? stage.careTe : stage.careEn };
}