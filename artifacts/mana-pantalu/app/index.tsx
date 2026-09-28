import React from 'react';
import { Image, Pressable, StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { useApp } from '@/context/AppContext';
import { LanguageToggle, PrimaryButton, Screen } from '@/components/Ui';
import colors from '@/constants/colors';

export default function WelcomeScreen() {
  const { language, completeWelcome, hydrated, welcomeSeen } = useApp();
  React.useEffect(() => {
    if (hydrated && welcomeSeen) router.replace('/(tabs)');
  }, [hydrated, welcomeSeen]);
  if (!hydrated) return null;
  const te = language === 'te';
  return <Screen scroll={false} bottom={28}>
    <View style={styles.wrap}>
      <View style={styles.brandRow}><Image source={require('@/assets/images/icon.png')} style={styles.logo} /><View><Text style={styles.brand}>మన పంటలు</Text><Text style={styles.brandEn}>MANA PANTALU</Text></View></View>
      <View style={styles.hero}>
        <View style={styles.sun} /><View style={[styles.leaf, styles.leafOne]} /><View style={[styles.leaf, styles.leafTwo]} /><View style={styles.soil} />
        <Text style={styles.heroKicker}>{te ? 'మీ పంటకు మీతో పాటు' : 'By your side, for your crop'}</Text>
        <Text style={styles.heroTitle}>{te ? 'పంటను గమనించండి.\nసరైన నిర్ణయం తీసుకోండి.' : 'See your crop clearly.\nMake the next move.'}</Text>
        <Text style={styles.heroBody}>{te ? 'ఆకు ఫోటో, వాతావరణం మరియు సులభమైన సూచనలు — మీ భాషలో.' : 'Leaf diagnosis, weather, and simple guidance — in your language.'}</Text>
      </View>
      <View style={styles.footer}><PrimaryButton label={te ? 'ప్రారంభించండి' : 'Get started'} icon="arrow-right" onPress={() => { completeWelcome(); router.replace('/(tabs)'); }} /><LanguageToggle /><Text style={styles.note}>{te ? 'ఇది సూచన మాత్రమే. ముఖ్యమైన నిర్ణయాలకు వ్యవసాయ అధికారిని సంప్రదించండి.' : 'Guidance only. Confirm important decisions with your agriculture officer.'}</Text></View>
    </View>
  </Screen>;
}

const styles = StyleSheet.create({
  wrap: { flex: 1, justifyContent: 'space-between', gap: 24 },
  brandRow: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  logo: { width: 52, height: 52, borderRadius: 16 },
  brand: { color: colors.deep, fontSize: 23, fontWeight: '900' },
  brandEn: { color: colors.mutedForeground, fontSize: 10, fontWeight: '800', letterSpacing: 1.5, marginTop: 2 },
  hero: { backgroundColor: colors.secondary, borderRadius: 30, padding: 24, minHeight: 440, justifyContent: 'flex-end', overflow: 'hidden', position: 'relative' },
  sun: { position: 'absolute', width: 150, height: 150, borderRadius: 75, backgroundColor: '#F6C45F', right: -25, top: -20, opacity: 0.8 },
  soil: { position: 'absolute', height: 104, left: -20, right: -20, bottom: 0, backgroundColor: '#7C5A3E', borderTopLeftRadius: 80, borderTopRightRadius: 120, transform: [{ rotate: '-4deg' }] },
  leaf: { position: 'absolute', backgroundColor: colors.primary, width: 106, height: 180, borderTopLeftRadius: 100, borderTopRightRadius: 20, borderBottomLeftRadius: 20, borderBottomRightRadius: 100, bottom: 170 },
  leafOne: { left: 66, transform: [{ rotate: '-28deg' }] },
  leafTwo: { left: 137, height: 210, bottom: 155, transform: [{ rotate: '21deg' }], backgroundColor: '#4F8A54' },
  heroKicker: { color: colors.primary, fontSize: 16, fontWeight: '900', marginBottom: 12 },
  heroTitle: { color: colors.deep, fontSize: 30, lineHeight: 38, fontWeight: '900', zIndex: 1 },
  heroBody: { color: colors.text, fontSize: 16, lineHeight: 24, marginTop: 16, maxWidth: 300, zIndex: 1 },
  footer: { gap: 14 },
  note: { color: colors.mutedForeground, fontSize: 13, lineHeight: 19, textAlign: 'center' },
});