import React from 'react';
import { Alert, Image, Pressable, StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import * as ImagePicker from 'expo-image-picker';
import { Feather } from '@expo/vector-icons';
import { InfoBanner, PrimaryButton, Screen, SecondaryButton, SectionTitle, VoiceButton, Header, LoadingState } from '@/components/Ui';
import { cropById, disease, Language } from '@/data/mockData';
import { useApp } from '@/context/AppContext';
import colors from '@/constants/colors';

type Phase = 'capture' | 'picked' | 'scanning' | 'result' | 'low';

export default function DiagnoseScreen() {
  const { language, addScan } = useApp();
  const te = language === 'te';
  const [phase, setPhase] = React.useState<Phase>('capture');
  const [uri, setUri] = React.useState<string>();
  const [scanId, setScanId] = React.useState('');
  const [count, setCount] = React.useState(0);
  const pick = async (camera: boolean) => {
    try {
      const permission = camera ? await ImagePicker.requestCameraPermissionsAsync() : await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (!permission.granted) {
        Alert.alert(te ? 'అనుమతి అవసరం' : 'Permission needed', te ? 'కెమెరా లేదా గ్యాలరీ అనుమతిని సెట్టింగ్స్‌లో ఇవ్వండి.' : 'Allow camera or gallery access in Settings.');
        return;
      }
      const result = camera ? await ImagePicker.launchCameraAsync({ mediaTypes: ImagePicker.MediaTypeOptions.Images, quality: 0.8, allowsEditing: true, aspect: [4, 3] }) : await ImagePicker.launchImageLibraryAsync({ mediaTypes: ImagePicker.MediaTypeOptions.Images, quality: 0.8, allowsEditing: true, aspect: [4, 3] });
      if (!result.canceled && result.assets[0]) { setUri(result.assets[0].uri); setPhase('picked'); }
    } catch { Alert.alert(te ? 'ఫోటో తీసుకోలేకపోయాం' : 'Could not open photos', te ? 'మళ్ళీ ప్రయత్నించండి.' : 'Please try again.'); }
  };
  const analyze = () => {
    const nextCount = count + 1;
    setCount(nextCount);
    setPhase('scanning');
    setTimeout(() => {
      const low = nextCount % 3 === 0;
      const id = `${Date.now()}-${nextCount}`;
      setScanId(id);
      addScan({ id, uri, date: new Date().toISOString(), status: low ? 'low' : 'done', cropId: low ? undefined : 'rice', diseaseId: low ? undefined : disease.id, confidence: low ? 0.41 : 0.92 });
      setPhase(low ? 'low' : 'result');
    }, 1800);
  };
  if (phase === 'scanning') return <Screen scroll={false}><View style={styles.scanWrap}><Header title={te ? 'పంట పరీక్ష' : 'Crop check'} back onBack={() => setPhase('capture')} /><View style={styles.scanPhoto}>{uri ? <Image source={{ uri }} style={styles.photo} /> : <View style={styles.photoPlaceholder}><Feather name="image" size={32} color={colors.mutedForeground} /></View>}<View style={styles.scanLine} /></View><LoadingState label={te ? 'పంటను పరిశీలిస్తోంది…' : 'Checking your crop…'} /><SecondaryButton label={te ? 'రద్దు' : 'Cancel'} onPress={() => setPhase('capture')} /></View></Screen>;
  if (phase === 'picked') return <Screen><Header title={te ? 'ఫోటో చూడండి' : 'Review photo'} back onBack={() => setPhase('capture')} /><View style={styles.previewWrap}><Image source={{ uri }} style={styles.preview} /><InfoBanner>{te ? 'ఆకు స్పష్టంగా కనిపిస్తుందా? సిద్ధంగా ఉంటే పరీక్షించండి.' : 'Can you see the leaf clearly? Check it when ready.'}</InfoBanner><PrimaryButton label={te ? 'పరీక్ష ప్రారంభించండి' : 'Start diagnosis'} icon="search" onPress={analyze} /><SecondaryButton label={te ? 'మళ్ళీ ఫోటో' : 'Retake photo'} icon="refresh-cw" onPress={() => setPhase('capture')} /></View></Screen>;
  if (phase === 'result') return <ResultView language={language} uri={uri} scanId={scanId} onAgain={() => { setUri(undefined); setPhase('capture'); }} />;
  if (phase === 'low') return <LowView language={language} onAgain={() => { setUri(undefined); setPhase('capture'); }} />;
  return <Screen><Header title={te ? 'పంట పరీక్ష' : 'Crop check'} subtitle={te ? 'ఒక ఆకును దగ్గరగా ఫోటో తీయండి' : 'Photograph one leaf up close'} /><View style={styles.guideCard}><View style={styles.guideFrame}><Feather name="maximize" size={54} color={colors.primary} /><View style={styles.guideLeaf}><Feather name="feather" size={48} color={colors.primary} /></View></View><Text style={styles.guideTitle}>{te ? 'ఒక ఆకును ఫ్రేమ్‌లో ఉంచండి' : 'Place one leaf in the frame'}</Text><Text style={styles.guideBody}>{te ? 'మంచి వెలుతురు. ఒక ఆకు మాత్రమే. దగ్గరగా.' : 'Good light. One leaf only. Up close.'}</Text></View><View style={{ gap: 12 }}><PrimaryButton label={te ? 'కెమెరాతో ఫోటో తీయండి' : 'Take a photo'} icon="camera" onPress={() => pick(true)} /><SecondaryButton label={te ? 'గ్యాలరీ నుంచి ఎంచుకోండి' : 'Choose from gallery'} icon="image" onPress={() => pick(false)} /></View><InfoBanner>{te ? 'ఫోటో స్పష్టంగా లేకపోతే “ఖచ్చితంగా చెప్పలేకపోతున్నాం” అని చూపిస్తాం.' : 'If the photo is unclear, we will say we are not sure.'}</InfoBanner></Screen>;
}

function ResultView({ language, uri, onAgain, scanId }: { language: Language; uri?: string; scanId: string; onAgain: () => void }) {
  const te = language === 'te';
  const sections = [
    { title: te ? 'లక్షణాలు' : 'Symptoms', items: te ? disease.symptomsTe : disease.symptomsEn },
    { title: te ? 'కారణాలు' : 'Causes', items: te ? disease.causesTe : disease.causesEn },
    { title: te ? 'నివారణ' : 'Prevention', items: te ? disease.preventionTe : disease.preventionEn },
    { title: te ? 'జాగ్రత్తలు' : 'Care', items: te ? disease.careTe : disease.careEn },
    { title: te ? 'చికిత్స' : 'Treatment', items: te ? disease.treatmentTe : disease.treatmentEn },
  ];
  return <Screen><Header title={te ? 'ఫలితం' : 'Result'} back onBack={() => router.replace('/(tabs)')} /><View style={styles.resultHero}>{uri ? <Image source={{ uri }} style={styles.resultPhoto} /> : <View style={[styles.resultPhoto, styles.photoPlaceholder]}><Feather name="image" size={28} color={colors.mutedForeground} /></View>}<View style={{ flex: 1, gap: 7 }}><Text style={styles.resultLabel}>{te ? 'గుర్తించిన పంట' : 'Detected crop'}</Text><Text style={styles.resultCrop}>{te ? 'వరి' : 'Rice'}</Text><Text style={styles.resultLabel}>{te ? 'సాధ్యమైన సమస్య' : 'Possible issue'}</Text><Text style={styles.resultDisease}>{te ? disease.te : disease.en}</Text></View><View style={styles.confidence}><Text style={styles.confidenceNumber}>92%</Text><Text style={styles.confidenceLabel}>{te ? 'నమ్మకం' : 'confidence'}</Text></View></View><View style={styles.resultTools}><VoiceButton language={language} text={`${te ? disease.te : disease.en}. ${(te ? disease.symptomsTe : disease.symptomsEn).join('. ')} ${(te ? disease.careTe : disease.careEn).join('. ')}`} /><Text style={styles.aiNote}>{te ? 'AI సూచన' : 'AI guidance'}</Text></View>{sections.map((section) => <View key={section.title} style={styles.sectionCard}><Text style={styles.sectionCardTitle}>{section.title}</Text>{section.items.map((item) => <View key={item} style={styles.step}><View style={styles.stepDot} /><Text style={styles.stepText}>{item}</Text></View>)}</View>)}<InfoBanner>{te ? 'ఇది సూచన మాత్రమే. మందు లేదా మోతాదు ముందు వ్యవసాయ అధికారిని సంప్రదించండి.' : 'Guidance only. Confirm products and doses with your agriculture officer.'}</InfoBanner><View style={styles.actionRow}><PrimaryButton label={te ? 'మళ్ళీ స్కాన్' : 'Scan again'} icon="refresh-cw" onPress={onAgain} /><Pressable onPress={() => Alert.alert(te ? 'సేవ్ అయింది' : 'Saved', te ? 'ఈ పరీక్ష చరిత్రలో సేవ్ అయింది.' : 'This scan is saved in history.')} style={styles.saveButton}><Feather name="bookmark" size={20} color={colors.deep} /><Text style={styles.saveText}>{te ? 'సేవ్' : 'Save'}</Text></Pressable></View><Text style={styles.scanId}>{te ? `పరీక్ష ID: ${scanId.slice(-6)}` : `Scan ID: ${scanId.slice(-6)}`}</Text></Screen>;
}

function LowView({ language, onAgain }: { language: Language; onAgain: () => void }) {
  const te = language === 'te';
  return <Screen><Header title={te ? 'ఫలితం' : 'Result'} back onBack={() => router.replace('/(tabs)')} /><View style={styles.lowCard}><View style={styles.lowIcon}><Feather name="help-circle" size={40} color={colors.warning} /></View><Text style={styles.lowTitle}>{te ? 'ఖచ్చితంగా చెప్పలేకపోతున్నాం' : 'We are not sure'}</Text><Text style={styles.lowBody}>{te ? 'ఫోటోలో ఆకు స్పష్టంగా కనిపించలేదు. తప్పు సూచన ఇవ్వకుండా మళ్ళీ ప్రయత్నించండి.' : 'The leaf was not clear enough. Rather than guess, please try again.'}</Text></View><InfoBanner tone="warning">{te ? 'ఒక ఆకు మాత్రమే, మంచి వెలుతురులో, దగ్గరగా ఫోటో తీయండి.' : 'Photograph one leaf, in good light, up close.'}</InfoBanner><PrimaryButton label={te ? 'మళ్ళీ ఫోటో తీయండి' : 'Retake photo'} icon="refresh-cw" onPress={onAgain} /><SecondaryButton label={te ? 'నిపుణుడిని అడగండి' : 'Ask an expert'} icon="phone" onPress={() => Alert.alert(te ? 'త్వరలో' : 'Coming soon', te ? 'మీ వ్యవసాయ అధికారితో మాట్లాడే లింక్ త్వరలో వస్తుంది.' : 'A link to your agriculture officer will be added soon.')} /></Screen>;
}

const styles = StyleSheet.create({
  scanWrap: { flex: 1, gap: 18 },
  scanPhoto: { height: 330, borderRadius: 26, overflow: 'hidden', backgroundColor: colors.secondary, position: 'relative', borderWidth: 1, borderColor: colors.border },
  photo: { width: '100%', height: '100%' },
  photoPlaceholder: { alignItems: 'center', justifyContent: 'center', backgroundColor: colors.secondary },
  scanLine: { height: 3, backgroundColor: '#F7D27C', left: 16, right: 16, position: 'absolute', top: '50%', shadowColor: '#F7D27C', shadowOpacity: 0.8, shadowRadius: 12 },
  previewWrap: { gap: 16 },
  preview: { width: '100%', height: 310, borderRadius: 24, resizeMode: 'cover' },
  guideCard: { borderRadius: 26, backgroundColor: colors.secondary, padding: 20, alignItems: 'center', gap: 12 },
  guideFrame: { height: 250, width: '100%', borderRadius: 22, borderWidth: 2, borderColor: colors.primary, borderStyle: 'dashed', alignItems: 'center', justifyContent: 'center', overflow: 'hidden' },
  guideLeaf: { width: 110, height: 150, borderRadius: 90, backgroundColor: '#BBDCB9', alignItems: 'center', justifyContent: 'center', transform: [{ rotate: '-22deg' }] },
  guideTitle: { fontSize: 21, fontWeight: '900', color: colors.deep, textAlign: 'center' },
  guideBody: { fontSize: 16, color: colors.text, textAlign: 'center' },
  resultHero: { backgroundColor: colors.secondary, borderRadius: 22, padding: 14, flexDirection: 'row', gap: 12, alignItems: 'center' },
  resultPhoto: { width: 94, height: 122, borderRadius: 16, resizeMode: 'cover' },
  resultLabel: { color: colors.mutedForeground, fontSize: 12, fontWeight: '800' },
  resultCrop: { color: colors.deep, fontSize: 20, fontWeight: '900' },
  resultDisease: { color: colors.deep, fontSize: 16, fontWeight: '800' },
  confidence: { alignSelf: 'flex-start', backgroundColor: '#D6EACF', paddingHorizontal: 9, paddingVertical: 7, borderRadius: 12, alignItems: 'center' },
  confidenceNumber: { fontSize: 18, color: colors.primary, fontWeight: '900' },
  confidenceLabel: { color: colors.primary, fontSize: 10, fontWeight: '800' },
  resultTools: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  aiNote: { color: colors.mutedForeground, fontSize: 13 },
  sectionCard: { backgroundColor: colors.card, borderRadius: 18, padding: 16, gap: 11, borderWidth: 1, borderColor: colors.border },
  sectionCardTitle: { color: colors.deep, fontSize: 18, fontWeight: '900' },
  step: { flexDirection: 'row', gap: 10, alignItems: 'flex-start' },
  stepDot: { width: 8, height: 8, borderRadius: 4, backgroundColor: colors.primary, marginTop: 8 },
  stepText: { color: colors.text, flex: 1, fontSize: 15, lineHeight: 22 },
  actionRow: { gap: 10 },
  saveButton: { minHeight: 52, borderRadius: 26, backgroundColor: colors.secondary, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 7 },
  saveText: { color: colors.deep, fontSize: 16, fontWeight: '800' },
  scanId: { textAlign: 'center', color: colors.mutedForeground, fontSize: 12 },
  lowCard: { backgroundColor: '#FFF3D9', borderRadius: 24, alignItems: 'center', padding: 26, gap: 14 },
  lowIcon: { width: 72, height: 72, borderRadius: 36, backgroundColor: '#FFE2A2', alignItems: 'center', justifyContent: 'center' },
  lowTitle: { color: colors.deep, fontSize: 24, fontWeight: '900', textAlign: 'center' },
  lowBody: { color: colors.text, fontSize: 16, lineHeight: 24, textAlign: 'center' },
});