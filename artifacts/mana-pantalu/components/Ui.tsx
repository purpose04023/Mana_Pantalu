import React from 'react';
import { ActivityIndicator, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Speech from 'expo-speech';
import { Language } from '@/data/mockData';
import { useApp } from '@/context/AppContext';
import colors from '@/constants/colors';

export function Screen({ children, scroll = true, bottom = 110 }: { children: React.ReactNode; scroll?: boolean; bottom?: number }) {
  const insets = useSafeAreaInsets();
  const content = <View style={[styles.screen, { paddingTop: insets.top + 12, paddingBottom: insets.bottom + bottom }]}>{children}</View>;
  return scroll ? <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.scrollContent}>{content}</ScrollView> : content;
}

export function Header({ title, subtitle, back, onBack, right }: { title: string; subtitle?: string; back?: boolean; onBack?: () => void; right?: React.ReactNode }) {
  const insets = useSafeAreaInsets();
  return <View style={[styles.header, { paddingTop: insets.top + 12 }]}>
    <View style={styles.headerStart}>
      {back ? <Pressable accessibilityLabel="Go back" onPress={onBack} style={styles.iconButton}><Feather name="arrow-left" size={22} color={colors.deep} /></Pressable> : null}
      <View style={{ flex: 1 }}>
        <Text style={styles.headerTitle}>{title}</Text>
        {subtitle ? <Text style={styles.headerSubtitle}>{subtitle}</Text> : null}
      </View>
    </View>
    {right}
  </View>;
}

export function PrimaryButton({ label, onPress, icon, disabled = false }: { label: string; onPress: () => void; icon?: keyof typeof Feather.glyphMap; disabled?: boolean }) {
  return <Pressable accessibilityRole="button" onPress={onPress} disabled={disabled} style={({ pressed }) => [styles.primaryButton, pressed && styles.pressed, disabled && styles.disabled]}>
    {icon ? <Feather name={icon} size={20} color={colors.primaryForeground} /> : null}
    <Text style={styles.primaryButtonText}>{label}</Text>
  </Pressable>;
}

export function SecondaryButton({ label, onPress, icon }: { label: string; onPress: () => void; icon?: keyof typeof Feather.glyphMap }) {
  return <Pressable accessibilityRole="button" onPress={onPress} style={({ pressed }) => [styles.secondaryButton, pressed && styles.pressed]}>
    {icon ? <Feather name={icon} size={19} color={colors.deep} /> : null}
    <Text style={styles.secondaryButtonText}>{label}</Text>
  </Pressable>;
}

export function VoiceButton({ text, language, compact = false }: { text: string; language: Language; compact?: boolean }) {
  const [speaking, setSpeaking] = React.useState(false);
  const speak = () => {
    if (speaking) {
      Speech.stop();
      setSpeaking(false);
      return;
    }
    setSpeaking(true);
    Speech.speak(text, { language: language === 'te' ? 'te-IN' : 'en-IN', rate: 0.86, onDone: () => setSpeaking(false), onStopped: () => setSpeaking(false), onError: () => setSpeaking(false) });
  };
  return <Pressable accessibilityLabel={speaking ? 'Stop voice' : 'Play voice'} onPress={speak} style={[styles.voiceButton, compact && styles.voiceButtonCompact]}>
    <Feather name={speaking ? 'square' : 'volume-2'} size={compact ? 17 : 21} color={colors.deep} />
    {!compact ? <Text style={styles.voiceText}>{language === 'te' ? 'వినండి' : 'Listen'}</Text> : null}
  </Pressable>;
}

export function LanguageToggle() {
  const { language, setLanguage } = useApp();
  return <View style={styles.languageToggle}>
    <Pressable onPress={() => setLanguage('te')} style={[styles.languageOption, language === 'te' && styles.languageActive]}><Text style={[styles.languageText, language === 'te' && styles.languageActiveText]}>తెలుగు</Text></Pressable>
    <Pressable onPress={() => setLanguage('en')} style={[styles.languageOption, language === 'en' && styles.languageActive]}><Text style={[styles.languageText, language === 'en' && styles.languageActiveText]}>English</Text></Pressable>
  </View>;
}

export function SectionTitle({ title, action, onAction }: { title: string; action?: string; onAction?: () => void }) {
  return <View style={styles.sectionTitle}><Text style={styles.sectionTitleText}>{title}</Text>{action ? <Pressable onPress={onAction}><Text style={styles.sectionAction}>{action}</Text></Pressable> : null}</View>;
}

export function InfoBanner({ children, tone = 'soft' }: { children: React.ReactNode; tone?: 'soft' | 'warning' }) {
  return <View style={[styles.infoBanner, tone === 'warning' && styles.warningBanner]}><Feather name={tone === 'warning' ? 'alert-triangle' : 'info'} size={18} color={tone === 'warning' ? colors.warning : colors.deep} /><Text style={styles.infoText}>{children}</Text></View>;
}

export function LoadingState({ label }: { label: string }) {
  return <View style={styles.loading}><ActivityIndicator size="large" color={colors.primary} /><Text style={styles.loadingText}>{label}</Text></View>;
}

export function FormField({ label, value, onChangeText, placeholder, keyboardType = 'default' }: { label: string; value: string; onChangeText: (value: string) => void; placeholder: string; keyboardType?: 'default' | 'numeric' }) {
  return <View style={{ gap: 8 }}><Text style={styles.fieldLabel}>{label}</Text><TextInput value={value} onChangeText={onChangeText} placeholder={placeholder} placeholderTextColor={colors.mutedForeground} keyboardType={keyboardType} style={styles.input} /></View>;
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.background, paddingHorizontal: 20, gap: 20 },
  scrollContent: { flexGrow: 1, backgroundColor: colors.background },
  header: { backgroundColor: colors.background, paddingHorizontal: 20, paddingBottom: 8, flexDirection: 'row', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 },
  headerStart: { flexDirection: 'row', alignItems: 'center', gap: 10, flex: 1 },
  headerTitle: { fontSize: 27, lineHeight: 34, fontWeight: '800', color: colors.deep },
  headerSubtitle: { color: colors.mutedForeground, fontSize: 15, marginTop: 2 },
  iconButton: { width: 46, height: 46, borderRadius: 23, backgroundColor: colors.card, borderWidth: 1, borderColor: colors.border, alignItems: 'center', justifyContent: 'center' },
  primaryButton: { minHeight: 58, borderRadius: 29, backgroundColor: colors.primary, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 10, paddingHorizontal: 24 },
  primaryButtonText: { color: colors.primaryForeground, fontSize: 18, fontWeight: '800' },
  secondaryButton: { minHeight: 56, borderRadius: 28, backgroundColor: colors.secondary, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 9, paddingHorizontal: 20 },
  secondaryButtonText: { color: colors.deep, fontSize: 17, fontWeight: '700' },
  pressed: { opacity: 0.78, transform: [{ scale: 0.98 }] },
  disabled: { opacity: 0.5 },
  voiceButton: { minHeight: 56, borderRadius: 28, paddingHorizontal: 18, backgroundColor: colors.secondary, flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 8 },
  voiceButtonCompact: { minHeight: 44, width: 44, paddingHorizontal: 0, borderRadius: 22 },
  voiceText: { color: colors.deep, fontWeight: '800', fontSize: 16 },
  languageToggle: { flexDirection: 'row', backgroundColor: colors.secondary, padding: 4, borderRadius: 26, alignSelf: 'flex-start' },
  languageOption: { minHeight: 42, paddingHorizontal: 16, borderRadius: 21, justifyContent: 'center' },
  languageActive: { backgroundColor: colors.primary },
  languageText: { color: colors.deep, fontSize: 15, fontWeight: '700' },
  languageActiveText: { color: colors.primaryForeground },
  sectionTitle: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', gap: 12 },
  sectionTitleText: { fontSize: 20, fontWeight: '800', color: colors.deep },
  sectionAction: { color: colors.primary, fontSize: 15, fontWeight: '800' },
  infoBanner: { borderRadius: 16, padding: 14, backgroundColor: colors.soft, flexDirection: 'row', gap: 10, alignItems: 'flex-start' },
  warningBanner: { backgroundColor: '#FFF3D9' },
  infoText: { color: colors.text, flex: 1, lineHeight: 23, fontSize: 15 },
  loading: { alignItems: 'center', justifyContent: 'center', gap: 16, flex: 1 },
  loadingText: { color: colors.mutedForeground, fontSize: 17, fontWeight: '700' },
  fieldLabel: { fontSize: 16, fontWeight: '800', color: colors.deep },
  input: { minHeight: 56, borderRadius: 16, borderWidth: 1, borderColor: colors.input, backgroundColor: colors.card, paddingHorizontal: 16, color: colors.text, fontSize: 17 },
});

export const uiStyles = styles;