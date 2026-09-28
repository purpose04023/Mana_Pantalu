import React from 'react';
import { Alert, Pressable, StyleSheet, Switch, Text, View } from 'react-native';
import { router } from 'expo-router';
import { Feather } from '@expo/vector-icons';
import { Header, InfoBanner, LanguageToggle, Screen, SectionTitle } from '@/components/Ui';
import { useApp } from '@/context/AppContext';
import colors from '@/constants/colors';

export default function ProfileScreen() {
  const { language, notifications, setNotifications, scans } = useApp();
  const te = language === 'te';
  const rows = [
    { icon: 'clock' as const, label: te ? 'పరీక్ష చరిత్ర' : 'Scan history', action: () => router.push('/history') },
    { icon: 'message-circle' as const, label: te ? 'సహాయం & అభిప్రాయం' : 'Help & feedback', action: () => router.push('/feedback') },
    { icon: 'map-pin' as const, label: te ? 'స్థానం: గుంటూరు' : 'Location: Guntur', action: () => Alert.alert(te ? 'స్థానం' : 'Location', te ? 'వాతావరణం కోసం డిఫాల్ట్‌గా గుంటూరును వాడుతున్నాం.' : 'Guntur is used as the default location for weather.') },
  ];
  return <Screen><Header title={te ? 'ప్రొఫైల్' : 'Profile'} subtitle={te ? 'మీ ప్రాధాన్యతలు' : 'Your preferences'} /><View style={styles.profileHero}><View style={styles.avatar}><Feather name="user" size={28} color={colors.deep} /></View><View><Text style={styles.name}>{te ? 'రైతు' : 'Farmer'}</Text><Text style={styles.member}>{te ? 'అతిథి ఖాతా · డేటా ఈ ఫోన్‌లో సేవ్ అవుతుంది' : 'Guest account · data stays on this phone'}</Text></View></View><SectionTitle title={te ? 'భాష' : 'Language'} /><LanguageToggle /><SectionTitle title={te ? 'సెట్టింగ్స్' : 'Settings'} /><View style={styles.settings}>{rows.map((row) => <Pressable key={row.label} onPress={row.action} style={styles.row}><View style={styles.rowIcon}><Feather name={row.icon} size={19} color={colors.deep} /></View><Text style={styles.rowLabel}>{row.label}</Text><Feather name="chevron-right" size={20} color={colors.mutedForeground} /></Pressable>)}<View style={styles.row}><View style={styles.rowIcon}><Feather name="bell" size={19} color={colors.deep} /></View><Text style={styles.rowLabel}>{te ? 'రిమైండర్లు' : 'Reminders'}</Text><Switch value={notifications} onValueChange={setNotifications} trackColor={{ false: colors.border, true: '#9FCAA0' }} thumbColor={notifications ? colors.primary : '#fff'} /></View></View><InfoBanner>{te ? 'పంట నిర్ధారణలో తప్పు ఉండవచ్చు. మందు మరియు మోతాదు కోసం అధికారిని సంప్రదించండి.' : 'Diagnoses can be wrong. Confirm products and doses with an agriculture officer.'}</InfoBanner><Text style={styles.version}>{te ? `మన పంటలు · ప్రోటోటైప్ · ${scans.length} పరీక్షలు` : `Mana Pantalu · Prototype · ${scans.length} scans`}</Text></Screen>;
}

const styles = StyleSheet.create({
  profileHero: { padding: 18, borderRadius: 22, backgroundColor: colors.secondary, flexDirection: 'row', gap: 14, alignItems: 'center' },
  avatar: { width: 58, height: 58, borderRadius: 29, backgroundColor: '#B9D8B8', alignItems: 'center', justifyContent: 'center' },
  name: { color: colors.deep, fontSize: 21, fontWeight: '900' },
  member: { color: colors.mutedForeground, fontSize: 13, marginTop: 4, maxWidth: 240 },
  settings: { backgroundColor: colors.card, borderRadius: 20, borderWidth: 1, borderColor: colors.border, paddingHorizontal: 14 },
  row: { minHeight: 65, flexDirection: 'row', alignItems: 'center', gap: 12, borderBottomWidth: 1, borderBottomColor: colors.border },
  rowIcon: { width: 38, height: 38, borderRadius: 13, backgroundColor: colors.secondary, alignItems: 'center', justifyContent: 'center' },
  rowLabel: { color: colors.deep, flex: 1, fontSize: 16, fontWeight: '700' },
  version: { textAlign: 'center', color: colors.mutedForeground, fontSize: 13 },
});