import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { Feather } from '@expo/vector-icons';
import { Screen, SectionTitle, VoiceButton } from '@/components/Ui';
import { useApp } from '@/context/AppContext';
import { cropById, tips } from '@/data/mockData';
import colors from '@/constants/colors';

const tileIcons: Record<string, keyof typeof Feather.glyphMap> = { diagnose: 'camera', weather: 'cloud-rain', crops: 'grid', tips: 'sun', myCrops: 'map', help: 'message-circle' };

export default function HomeScreen() {
  const { language } = useApp();
  const te = language === 'te';
  const tiles = [
    { id: 'diagnose', te: 'పంట పరీక్ష', en: 'Diagnose', route: '/diagnose' },
    { id: 'weather', te: 'వాతావరణం', en: 'Weather', route: '/weather' },
    { id: 'crops', te: 'పంటల గ్రంథాలయం', en: 'Crop library', route: '/crop-detail' },
    { id: 'tips', te: 'సూచనలు', en: 'Tips', route: '/tips' },
    { id: 'myCrops', te: 'నా పంటలు', en: 'My crops', route: '/my-crops' },
    { id: 'help', te: 'సహాయం', en: 'Help & feedback', route: '/feedback' },
  ];
  return <Screen>
    <View style={styles.top}><View><Text style={styles.eyebrow}>{te ? 'మన పంటలు' : 'MANA PANTALU'}</Text><Text style={styles.greeting}>{te ? 'నమస్కారం, రైతు' : 'Good morning, farmer'}</Text></View><View style={styles.topActions}><Pressable onPress={() => router.push('/weather')} style={styles.roundButton}><Feather name="cloud" size={20} color={colors.deep} /></Pressable><Pressable onPress={() => router.push('/profile')} style={[styles.roundButton, { backgroundColor: colors.primary }]}><Feather name="user" size={20} color="#fff" /></Pressable></View></View>
    <View style={styles.heroCard}><View style={{ flex: 1, gap: 9 }}><Text style={styles.heroLabel}>{te ? 'ఈ రోజు చేయాల్సింది' : 'Today’s next step'}</Text><Text style={styles.heroText}>{te ? 'ఒక ఆకును ఫోటో తీసి పంట పరిస్థితిని తెలుసుకోండి.' : 'Photograph one leaf to understand your crop.'}</Text><Pressable onPress={() => router.push('/diagnose')}><Text style={styles.heroLink}>{te ? 'పంటను పరీక్షించండి  →' : 'Check a crop  →'}</Text></Pressable></View><View style={styles.heroIcon}><Feather name="camera" size={28} color={colors.deep} /></View></View>
    <SectionTitle title={te ? 'మీకు కావలసినది' : 'What do you need?'} />
    <View style={styles.grid}>{tiles.map((tile) => <Pressable key={tile.id} onPress={() => router.push(tile.route as never)} style={({ pressed }) => [styles.tile, pressed && { opacity: 0.78 }]}><View style={styles.tileIcon}><Feather name={tileIcons[tile.id]} size={23} color={colors.deep} /></View><Text style={styles.tileTitle}>{te ? tile.te : tile.en}</Text><Text style={styles.tileSub}>{te ? tile.en : tile.te}</Text></Pressable>)}</View>
    <SectionTitle title={te ? 'ఈ రోజు సూచన' : "Today's tip"} action={te ? 'అన్నీ చూడండి' : 'See all'} onAction={() => router.push('/tips')} />
    <View style={styles.tipCard}><View style={styles.tipMark}><Feather name="sun" size={20} color={colors.warning} /></View><View style={{ flex: 1, gap: 6 }}><Text style={styles.tipTitle}>{te ? tips[0].titleTe : tips[0].titleEn}</Text><Text style={styles.tipBody}>{te ? tips[0].bodyTe : tips[0].bodyEn}</Text></View><VoiceButton language={language} text={te ? `${tips[0].titleTe}. ${tips[0].bodyTe}` : `${tips[0].titleEn}. ${tips[0].bodyEn}`} compact /></View>
    <SectionTitle title={te ? 'మీ పంట' : 'Your crop'} action={te ? 'చూడండి' : 'View'} onAction={() => router.push('/my-crops')} />
    <Pressable onPress={() => router.push('/my-crops')} style={styles.cropPeek}><View style={styles.cropBadge}>🌾</View><View style={{ flex: 1 }}><Text style={styles.cropPeekTitle}>{te ? 'వరి' : 'Rice'}</Text><Text style={styles.cropPeekSub}>{te ? 'గుంటూరు · 2.5 ఎకరాలు' : 'Guntur · 2.5 acres'}</Text></View><Feather name="chevron-right" size={22} color={colors.mutedForeground} /></Pressable>
  </Screen>;
}

const styles = StyleSheet.create({
  top: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  eyebrow: { color: colors.primary, fontSize: 13, fontWeight: '900', letterSpacing: 1.6 },
  greeting: { color: colors.deep, fontSize: 24, fontWeight: '900', marginTop: 3 },
  topActions: { flexDirection: 'row', gap: 8 },
  roundButton: { width: 44, height: 44, borderRadius: 22, backgroundColor: colors.secondary, alignItems: 'center', justifyContent: 'center' },
  heroCard: { backgroundColor: colors.primary, minHeight: 150, borderRadius: 24, padding: 20, flexDirection: 'row', alignItems: 'center', gap: 14 },
  heroLabel: { color: '#C9E4C6', fontSize: 14, fontWeight: '800' },
  heroText: { color: '#fff', fontSize: 20, lineHeight: 27, fontWeight: '800' },
  heroLink: { color: '#F7D27C', fontSize: 15, fontWeight: '900' },
  heroIcon: { width: 62, height: 62, borderRadius: 31, backgroundColor: '#B7D8B6', alignItems: 'center', justifyContent: 'center' },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 12 },
  tile: { width: '31.6%', minHeight: 117, backgroundColor: colors.card, borderRadius: 19, padding: 13, justifyContent: 'space-between', borderWidth: 1, borderColor: colors.border },
  tileIcon: { width: 39, height: 39, borderRadius: 13, backgroundColor: colors.secondary, alignItems: 'center', justifyContent: 'center' },
  tileTitle: { color: colors.deep, fontSize: 15, fontWeight: '900', lineHeight: 20, marginTop: 10 },
  tileSub: { color: colors.mutedForeground, fontSize: 11, marginTop: 2 },
  tipCard: { padding: 16, borderRadius: 20, backgroundColor: '#FFF7E5', flexDirection: 'row', gap: 12, alignItems: 'center' },
  tipMark: { width: 42, height: 42, borderRadius: 14, backgroundColor: '#FFE6A6', alignItems: 'center', justifyContent: 'center' },
  tipTitle: { color: colors.deep, fontSize: 16, fontWeight: '900' },
  tipBody: { color: colors.text, fontSize: 14, lineHeight: 20 },
  cropPeek: { minHeight: 78, borderRadius: 20, padding: 14, backgroundColor: colors.card, flexDirection: 'row', alignItems: 'center', gap: 12, borderWidth: 1, borderColor: colors.border },
  cropBadge: { width: 48, height: 48, borderRadius: 16, backgroundColor: '#DCEBC8', alignItems: 'center', justifyContent: 'center', fontSize: 24 },
  cropPeekTitle: { fontSize: 18, fontWeight: '900', color: colors.deep },
  cropPeekSub: { color: colors.mutedForeground, marginTop: 3 },
});