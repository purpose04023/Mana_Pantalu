import React from 'react';
import { Alert, Pressable, StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { Feather } from '@expo/vector-icons';
import { FormField, Header, PrimaryButton, Screen, SecondaryButton } from '@/components/Ui';
import { crops } from '@/data/mockData';
import { useApp } from '@/context/AppContext';
import colors from '@/constants/colors';

export default function AddCropScreen() {
  const { language, addCrop } = useApp();
  const te = language === 'te';
  const [cropId, setCropId] = React.useState('rice');
  const [date, setDate] = React.useState('2026-08-10');
  const [acres, setAcres] = React.useState('2.5');
  const [location, setLocation] = React.useState('Guntur');
  const save = () => {
    const numeric = Number(acres);
    if (!date || !location || !Number.isFinite(numeric) || numeric <= 0) {
      Alert.alert(te ? 'వివరాలు పూర్తి చేయండి' : 'Complete the details', te ? 'తేదీ, ఎకరాలు మరియు ప్రాంతాన్ని నమోదు చేయండి.' : 'Enter date, acres, and location.');
      return;
    }
    addCrop({ id: `${Date.now()}`, cropId, sowingDate: date, acres: numeric, location });
    router.replace('/my-crops');
  };
  return <Screen><Header title={te ? 'పంట జోడించండి' : 'Add a crop'} subtitle={te ? 'దాని దశను సులభంగా గమనించండి' : 'Track its stage simply'} back onBack={() => router.back()} /><View style={{ gap: 9 }}><Text style={styles.label}>{te ? 'పంట ఎంచుకోండి' : 'Choose a crop'}</Text><View style={styles.cropGrid}>{crops.slice(0, 6).map((crop) => <Pressable key={crop.id} onPress={() => setCropId(crop.id)} style={[styles.cropOption, cropId === crop.id && styles.cropOptionActive]}><View style={[styles.cropDot, { backgroundColor: crop.color }]}><Text>{crop.icon}</Text></View><Text style={[styles.cropOptionText, cropId === crop.id && styles.cropOptionTextActive]}>{te ? crop.te : crop.en}</Text>{cropId === crop.id ? <Feather name="check-circle" size={17} color={colors.primary} /> : null}</Pressable>)}</View></View><FormField label={te ? 'విత్తిన తేదీ' : 'Sowing date'} value={date} onChangeText={setDate} placeholder="YYYY-MM-DD" /><FormField label={te ? 'పొలం విస్తీర్ణం (ఎకరాలు)' : 'Field size (acres)'} value={acres} onChangeText={setAcres} placeholder="2.5" keyboardType="numeric" /><FormField label={te ? 'ప్రాంతం' : 'Location'} value={location} onChangeText={setLocation} placeholder={te ? 'గ్రామం లేదా జిల్లా' : 'Village or district'} /><PrimaryButton label={te ? 'సేవ్ చేయండి' : 'Save crop'} icon="check" onPress={save} /><SecondaryButton label={te ? 'రద్దు' : 'Cancel'} onPress={() => router.back()} /></Screen>;
}

const styles = StyleSheet.create({
  label: { color: colors.deep, fontSize: 16, fontWeight: '900' },
  cropGrid: { gap: 9 },
  cropOption: { minHeight: 57, borderRadius: 16, paddingHorizontal: 12, backgroundColor: colors.card, borderWidth: 1, borderColor: colors.border, flexDirection: 'row', alignItems: 'center', gap: 11 },
  cropOptionActive: { backgroundColor: colors.secondary, borderColor: colors.primary },
  cropDot: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  cropOptionText: { flex: 1, color: colors.deep, fontSize: 16, fontWeight: '700' },
  cropOptionTextActive: { fontWeight: '900' },
});