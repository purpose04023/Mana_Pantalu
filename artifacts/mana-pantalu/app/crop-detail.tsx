import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { router, useLocalSearchParams } from 'expo-router';
import { Feather } from '@expo/vector-icons';
import { Header, InfoBanner, Screen, SectionTitle } from '@/components/Ui';
import { cropById, stageFor } from '@/data/mockData';
import { useApp } from '@/context/AppContext';
import colors from '@/constants/colors';

export default function CropDetailScreen() {
  const { cropId } = useLocalSearchParams<{ cropId?: string }>();
  const { language, crops: userCrops } = useApp();
  const te = language === 'te';
  const crop = cropById(cropId ?? 'rice') ?? cropById('rice')!;
  const userCrop = userCrops.find((item) => item.cropId === crop.id);
  const stage = userCrop ? stageFor(userCrop, language) : null;
  return <Screen><Header title={te ? crop.te : crop.en} subtitle={te ? 'పంట సమాచారం' : 'Crop information'} back onBack={() => router.back()} /><View style={[styles.hero, { backgroundColor: crop.color }]}><Text style={styles.cropIcon}>{crop.icon}</Text><Text style={styles.heroName}>{te ? crop.te : crop.en}</Text><Text style={styles.heroBody}>{te ? crop.descriptionTe : crop.descriptionEn}</Text></View><SectionTitle title={te ? 'త్వరిత సమాచారం' : 'Quick facts'} /><View style={styles.facts}><Fact icon="calendar" value={`${crop.duration}`} label={te ? 'రోజుల కాలం' : 'days duration'} /><Fact icon="sun" value={userCrop ? `${stage?.days ?? 0}` : '—'} label={te ? 'విత్తిన తర్వాత రోజులు' : 'days since sowing'} /><Fact icon="check-circle" value={stage?.name ?? (te ? 'జోడించలేదు' : 'Not added')} label={te ? 'ప్రస్తుత దశ' : 'Current stage'} /></View><SectionTitle title={te ? 'తదుపరి పని' : 'Next action'} /><View style={styles.action}><Feather name="check-circle" size={25} color={colors.primary} /><Text style={styles.actionText}>{stage?.care ?? (te ? 'నా పంటల్లో జోడించి దశను చూడండి.' : 'Add it to My crops to see its stage.')}</Text></View><InfoBanner>{te ? 'పంటలో సమస్య కనిపిస్తే ఒక ఆకును ఫోటో తీసి పంట పరీక్ష ఉపయోగించండి.' : 'If you see a problem, photograph one leaf and use Crop check.'}</InfoBanner></Screen>;
}

function Fact({ icon, value, label }: { icon: keyof typeof Feather.glyphMap; value: string; label: string }) {
  return <View style={styles.fact}><Feather name={icon} size={18} color={colors.primary} /><Text style={styles.factValue}>{value}</Text><Text style={styles.factLabel}>{label}</Text></View>;
}

const styles = StyleSheet.create({
  hero: { borderRadius: 25, padding: 24, alignItems: 'center', gap: 10 },
  cropIcon: { fontSize: 55, color: colors.deep },
  heroName: { color: colors.deep, fontSize: 28, fontWeight: '900' },
  heroBody: { color: colors.text, textAlign: 'center', fontSize: 16, lineHeight: 23 },
  facts: { flexDirection: 'row', gap: 9 },
  fact: { flex: 1, backgroundColor: colors.card, borderRadius: 17, borderWidth: 1, borderColor: colors.border, padding: 12, gap: 6 },
  factValue: { color: colors.deep, fontSize: 18, fontWeight: '900' },
  factLabel: { color: colors.mutedForeground, fontSize: 11, lineHeight: 15 },
  action: { padding: 17, borderRadius: 20, backgroundColor: colors.secondary, flexDirection: 'row', gap: 12, alignItems: 'center' },
  actionText: { flex: 1, color: colors.deep, fontSize: 16, lineHeight: 23, fontWeight: '700' },
});