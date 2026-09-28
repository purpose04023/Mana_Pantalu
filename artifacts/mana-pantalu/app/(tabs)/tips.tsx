import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { Header, Screen, VoiceButton } from '@/components/Ui';
import { tips, Tip } from '@/data/mockData';
import { useApp } from '@/context/AppContext';
import colors from '@/constants/colors';

const categories = [
  { id: 'all', te: 'అన్నీ', en: 'All' },
  { id: 'crop_care', te: 'పంట సంరక్షణ', en: 'Crop care' },
  { id: 'fertilizer', te: 'ఎరువు', en: 'Fertilizer' },
  { id: 'irrigation', te: 'నీరు', en: 'Irrigation' },
  { id: 'pest', te: 'పురుగులు', en: 'Pests' },
];

export default function TipsScreen() {
  const { language, isTipSaved, saveTip } = useApp();
  const te = language === 'te';
  const [category, setCategory] = React.useState('all');
  const visible = category === 'all' ? tips : tips.filter((tip) => tip.category === category);
  return <Screen><Header title={te ? 'సూచనలు' : 'Tips'} subtitle={te ? 'చిన్న అడుగు, మంచి పంట' : 'Small steps for a healthier crop'} /><ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chips}>{categories.map((item) => <Pressable key={item.id} onPress={() => setCategory(item.id)} style={[styles.chip, category === item.id && styles.chipActive]}><Text style={[styles.chipText, category === item.id && styles.chipTextActive]}>{te ? item.te : item.en}</Text></Pressable>)}</ScrollView><View style={{ gap: 12 }}>{visible.map((tip) => <TipCard key={tip.id} tip={tip} te={te} saved={isTipSaved(tip.id)} onSave={() => saveTip(tip)} />)}</View></Screen>;
}

function TipCard({ tip, te, saved, onSave }: { tip: Tip; te: boolean; saved: boolean; onSave: () => void }) {
  return <View style={styles.card}><View style={styles.cardTop}><View style={styles.tipIcon}><Feather name={tip.category === 'pest' ? 'shield' : tip.category === 'irrigation' ? 'cloud-rain' : 'sun'} size={20} color={colors.deep} /></View><View style={{ flex: 1 }}><Text style={styles.title}>{te ? tip.titleTe : tip.titleEn}</Text><Text style={styles.body}>{te ? tip.bodyTe : tip.bodyEn}</Text></View><Pressable onPress={onSave} accessibilityLabel={saved ? 'Remove saved tip' : 'Save tip'}><Feather name={saved ? 'bookmark' : 'bookmark'} size={22} color={saved ? colors.primary : colors.mutedForeground} /></Pressable></View><View style={styles.cardBottom}><VoiceButton language={te ? 'te' : 'en'} text={te ? `${tip.titleTe}. ${tip.bodyTe}` : `${tip.titleEn}. ${tip.bodyEn}`} compact /><Text style={styles.read}>{te ? 'వినడానికి నొక్కండి' : 'Tap to listen'}</Text></View></View>;
}

const styles = StyleSheet.create({
  chips: { gap: 8, paddingRight: 20 },
  chip: { minHeight: 42, borderRadius: 21, paddingHorizontal: 15, justifyContent: 'center', backgroundColor: colors.secondary },
  chipActive: { backgroundColor: colors.primary },
  chipText: { color: colors.deep, fontSize: 14, fontWeight: '800' },
  chipTextActive: { color: '#fff' },
  card: { backgroundColor: colors.card, borderRadius: 21, padding: 16, borderWidth: 1, borderColor: colors.border, gap: 13 },
  cardTop: { flexDirection: 'row', gap: 12, alignItems: 'flex-start' },
  tipIcon: { width: 44, height: 44, borderRadius: 14, backgroundColor: colors.secondary, alignItems: 'center', justifyContent: 'center' },
  title: { color: colors.deep, fontSize: 17, fontWeight: '900', marginBottom: 5 },
  body: { color: colors.text, fontSize: 15, lineHeight: 22 },
  cardBottom: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  read: { color: colors.mutedForeground, fontSize: 13 },
});