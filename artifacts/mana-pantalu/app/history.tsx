import React from 'react';
import { Image, StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { Feather } from '@expo/vector-icons';
import { Header, Screen } from '@/components/Ui';
import { cropById, disease } from '@/data/mockData';
import { useApp } from '@/context/AppContext';
import colors from '@/constants/colors';

export default function HistoryScreen() {
  const { language, scans } = useApp();
  const te = language === 'te';
  return <Screen><Header title={te ? 'పరీక్ష చరిత్ర' : 'Scan history'} subtitle={te ? 'ఇటీవలి పరీక్షలు' : 'Your recent checks'} back onBack={() => router.back()} />{scans.map((scan) => { const crop = cropById(scan.cropId); return <View key={scan.id} style={styles.item}>{scan.uri ? <Image source={{ uri: scan.uri }} style={styles.image} /> : <View style={[styles.image, styles.imageFallback]}><Feather name="image" size={24} color={colors.mutedForeground} /></View>}<View style={{ flex: 1, gap: 5 }}><Text style={styles.date}>{new Date(scan.date).toLocaleDateString(te ? 'te-IN' : 'en-IN', { day: 'numeric', month: 'short' })}</Text><Text style={styles.crop}>{scan.status === 'done' ? (te ? `${crop?.te ?? 'పంట'} · ${disease.te}` : `${crop?.en ?? 'Crop'} · ${disease.en}`) : (te ? 'ఖచ్చితంగా చెప్పలేకపోయాం' : 'Low confidence')}</Text><Text style={styles.meta}>{Math.round(scan.confidence * 100)}% · {scan.status === 'done' ? (te ? 'స్పష్టమైన ఫలితం' : 'Clear result') : (te ? 'మళ్ళీ ఫోటో తీయండి' : 'Retake recommended')}</Text></View><Feather name={scan.status === 'done' ? 'check-circle' : 'help-circle'} size={22} color={scan.status === 'done' ? colors.primary : colors.warning} /></View>; })}</Screen>;
}

const styles = StyleSheet.create({
  item: { minHeight: 90, backgroundColor: colors.card, borderRadius: 20, padding: 12, borderWidth: 1, borderColor: colors.border, flexDirection: 'row', alignItems: 'center', gap: 12 },
  image: { width: 62, height: 62, borderRadius: 15 },
  imageFallback: { backgroundColor: colors.secondary, alignItems: 'center', justifyContent: 'center' },
  date: { color: colors.mutedForeground, fontSize: 12, fontWeight: '800' },
  crop: { color: colors.deep, fontSize: 16, fontWeight: '900' },
  meta: { color: colors.mutedForeground, fontSize: 13 },
});