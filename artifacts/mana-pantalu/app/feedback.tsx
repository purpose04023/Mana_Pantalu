import React from 'react';
import { Alert, StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { FormField, Header, PrimaryButton, Screen } from '@/components/Ui';
import { useApp } from '@/context/AppContext';
import colors from '@/constants/colors';

export default function FeedbackScreen() {
  const { language } = useApp();
  const te = language === 'te';
  const [message, setMessage] = React.useState('');
  const send = () => {
    if (!message.trim()) {
      Alert.alert(te ? 'సందేశం రాయండి' : 'Write a message', te ? 'మీ అభిప్రాయం మాకు సహాయపడుతుంది.' : 'Your feedback helps us improve.');
      return;
    }
    setMessage('');
    Alert.alert(te ? 'ధన్యవాదాలు' : 'Thank you', te ? 'మీ అభిప్రాయం పంపబడింది.' : 'Your feedback was sent.');
    router.back();
  };
  return <Screen><Header title={te ? 'సహాయం & అభిప్రాయం' : 'Help & feedback'} subtitle={te ? 'మీ మాట మాకు ముఖ్యం' : 'Your voice matters'} back onBack={() => router.back()} /><View style={styles.hero}><Text style={styles.heroTitle}>{te ? 'ఏం బాగా పనిచేసింది?' : 'What could work better?'}</Text><Text style={styles.heroBody}>{te ? 'మీ మాటలను రాయండి. వాయిస్ రికార్డింగ్ త్వరలో వస్తుంది.' : 'Write a note. Voice recording is coming soon.'}</Text></View><FormField label={te ? 'మీ సందేశం' : 'Your message'} value={message} onChangeText={setMessage} placeholder={te ? 'ఇక్కడ రాయండి…' : 'Type here…'} /><PrimaryButton label={te ? 'పంపండి' : 'Send feedback'} icon="send" onPress={send} /></Screen>;
}

const styles = StyleSheet.create({
  hero: { padding: 22, borderRadius: 23, backgroundColor: colors.secondary, gap: 9 },
  heroTitle: { color: colors.deep, fontSize: 24, fontWeight: '900' },
  heroBody: { color: colors.text, fontSize: 15, lineHeight: 22 },
});