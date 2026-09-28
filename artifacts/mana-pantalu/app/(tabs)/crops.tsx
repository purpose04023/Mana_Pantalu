import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { Feather } from '@expo/vector-icons';
import { Header, PrimaryButton, Screen, SectionTitle } from '@/components/Ui';
import { cropById, crops, stageFor } from '@/data/mockData';
import { useApp } from '@/context/AppContext';
import colors from '@/constants/colors';

export default function CropsScreen() {
  const { language, crops: myCrops } = useApp();
  const te = language === 'te';
  return <Screen>
    <Header title={te ? 'నా పంటలు' : 'My crops'} subtitle={te ? 'మీ పొలాల చిన్న జాబితా' : 'A simple list of your fields'} right={<Pressable onPress={() => router.push('/add-crop')} style={styles.addIcon}><Feather name="plus" size={22} color="#fff" /></Pressable>} />
    {myCrops.length > 0 ? <View style={{ gap: 12 }}>{myCrops.map((userCrop) => {
      const crop = cropById(userCrop.cropId);
      const stage = stageFor(userCrop, language);
      return <Pressable key={userCrop.id} onPress={() => router.push({ pathname: '/crop-detail', params: { cropId: userCrop.cropId } })} style={styles.myCropCard}>
        <View style={[styles.cropIcon, { backgroundColor: crop?.color ?? colors.secondary }]}><Text style={styles.cropIconText}>{crop?.icon ?? '•'}</Text></View>
        <View style={{ flex: 1, gap: 5 }}><Text style={styles.cropName}>{crop ? (te ? crop.te : crop.en) : userCrop.cropId}</Text><Text style={styles.cropMeta}>{userCrop.location} · {userCrop.acres} {te ? 'ఎకరాలు' : 'acres'}</Text><View style={styles.stagePill}><Text style={styles.stageText}>{stage.name}</Text></View><Text style={styles.care}>{stage.care}</Text></View>
        <Feather name="chevron-right" size={22} color={colors.mutedForeground} />
      </Pressable>;
    })}</View> : <View style={styles.empty}><View style={styles.emptyIcon}><Feather name="map" size={30} color={colors.primary} /></View><Text style={styles.emptyTitle}>{te ? 'ఇంకా పంటలు లేవు' : 'No crops yet'}</Text><Text style={styles.emptyBody}>{te ? 'మీ మొదటి పంటను జోడిస్తే దాని దశ మరియు తదుపరి పని కనిపిస్తాయి.' : 'Add your first crop to see its stage and next action.'}</Text></View>}
    <PrimaryButton label={te ? 'పంట జోడించండి' : 'Add a crop'} icon="plus" onPress={() => router.push('/add-crop')} />
    <SectionTitle title={te ? 'పంటల గ్రంథాలయం' : 'Crop library'} />
    <View style={styles.library}>{crops.map((crop) => <Pressable key={crop.id} onPress={() => router.push({ pathname: '/crop-detail', params: { cropId: crop.id } })} style={styles.libraryCard}><View style={[styles.cropIconSmall, { backgroundColor: crop.color }]}><Text style={styles.cropIconSmallText}>{crop.icon}</Text></View><Text style={styles.libraryTitle}>{te ? crop.te : crop.en}</Text></Pressable>)}</View>
  </Screen>;
}

const styles = StyleSheet.create({
  addIcon: { width: 46, height: 46, borderRadius: 23, backgroundColor: colors.primary, alignItems: 'center', justifyContent: 'center' },
  myCropCard: { backgroundColor: colors.card, borderRadius: 22, padding: 14, borderWidth: 1, borderColor: colors.border, flexDirection: 'row', alignItems: 'flex-start', gap: 12 },
  cropIcon: { width: 56, height: 56, borderRadius: 18, alignItems: 'center', justifyContent: 'center' },
  cropIconText: { fontSize: 26, color: colors.deep, fontWeight: '900' },
  cropName: { color: colors.deep, fontSize: 20, fontWeight: '900' },
  cropMeta: { color: colors.mutedForeground, fontSize: 14 },
  stagePill: { alignSelf: 'flex-start', backgroundColor: colors.secondary, borderRadius: 12, paddingHorizontal: 9, paddingVertical: 5 },
  stageText: { color: colors.primary, fontSize: 12, fontWeight: '900' },
  care: { color: colors.text, fontSize: 14, lineHeight: 20 },
  empty: { backgroundColor: colors.secondary, borderRadius: 24, padding: 28, alignItems: 'center', gap: 10 },
  emptyIcon: { width: 64, height: 64, borderRadius: 32, backgroundColor: '#CCE2C9', alignItems: 'center', justifyContent: 'center' },
  emptyTitle: { color: colors.deep, fontSize: 21, fontWeight: '900' },
  emptyBody: { color: colors.text, fontSize: 15, lineHeight: 22, textAlign: 'center' },
  library: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  libraryCard: { width: '23.6%', minHeight: 88, backgroundColor: colors.card, borderRadius: 16, borderWidth: 1, borderColor: colors.border, alignItems: 'center', justifyContent: 'center', gap: 8 },
  cropIconSmall: { width: 38, height: 38, borderRadius: 13, alignItems: 'center', justifyContent: 'center' },
  cropIconSmallText: { fontSize: 19, color: colors.deep },
  libraryTitle: { color: colors.deep, fontSize: 13, fontWeight: '800' },
});