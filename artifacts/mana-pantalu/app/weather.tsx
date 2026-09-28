import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import * as Location from 'expo-location';
import { Feather } from '@expo/vector-icons';
import { Header, InfoBanner, LoadingState, Screen, VoiceButton } from '@/components/Ui';
import { useApp } from '@/context/AppContext';
import colors from '@/constants/colors';

type WeatherData = { temp: number; humidity: number; wind: number; rain: number; highs: number[]; lows: number[]; rainDays: number[] };
const fallback: WeatherData = { temp: 31, humidity: 78, wind: 14, rain: 60, highs: [32, 31, 33], lows: [25, 24, 25], rainDays: [60, 35, 20] };

export default function WeatherScreen() {
  const { language } = useApp();
  const te = language === 'te';
  const [weather, setWeather] = React.useState<WeatherData | null>(null);
  const [loading, setLoading] = React.useState(true);
  const [locationName, setLocationName] = React.useState(te ? 'గుంటూరు' : 'Guntur');
  const load = async () => {
    setLoading(true);
    try {
      let latitude = 16.31;
      let longitude = 80.44;
      const permission = await Location.requestForegroundPermissionsAsync();
      if (permission.granted) {
        const position = await Location.getCurrentPositionAsync({ accuracy: Location.Accuracy.Balanced });
        latitude = position.coords.latitude;
        longitude = position.coords.longitude;
        setLocationName(te ? 'మీ ప్రస్తుత స్థానం' : 'Your current location');
      }
      const response = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,wind_speed_10m&daily=precipitation_probability_max,temperature_2m_max,temperature_2m_min&timezone=Asia%2FKolkata&forecast_days=3`);
      const json = await response.json();
      setWeather({ temp: Math.round(json.current.temperature_2m), humidity: Math.round(json.current.relative_humidity_2m), wind: Math.round(json.current.wind_speed_10m), rain: Math.round(json.daily.precipitation_probability_max[1] ?? 0), highs: json.daily.temperature_2m_max.map((value: number) => Math.round(value)), lows: json.daily.temperature_2m_min.map((value: number) => Math.round(value)), rainDays: json.daily.precipitation_probability_max.map((value: number) => Math.round(value)) });
    } catch { setWeather(fallback); }
    finally { setLoading(false); }
  };
  React.useEffect(() => { void load(); }, []);
  if (loading || !weather) return <Screen scroll={false}><Header title={te ? 'వాతావరణం' : 'Weather'} back onBack={() => router.back()} /><LoadingState label={te ? 'వాతావరణం చూస్తున్నాం…' : 'Loading weather…'} /></Screen>;
  const alert = weather.rain >= 60 ? (te ? 'రేపు వర్షం వచ్చే అవకాశం ఉంది. మందు పిచికారీ వాయిదా వేయండి.' : 'Rain likely tomorrow. Delay spraying.') : weather.humidity >= 85 ? (te ? 'తేమ ఎక్కువగా ఉంది. ఆకులపై తెగుళ్లు ఉన్నాయా చూడండి.' : 'Humidity is high. Inspect leaves for fungal disease.') : (te ? 'ఈ రోజు పొలాన్ని ఉదయం ఒకసారి చూడండి.' : 'Walk your field once this morning.');
  return <Screen><Header title={te ? 'వాతావరణం' : 'Weather'} subtitle={locationName} back onBack={() => router.back()} right={<Pressable onPress={() => void load()} style={styles.refresh}><Feather name="refresh-cw" size={18} color={colors.deep} /></Pressable>} /><View style={styles.current}><View><Text style={styles.currentTemp}>{weather.temp}°</Text><Text style={styles.condition}>{te ? 'పాక్షికంగా మేఘావృతం' : 'Partly cloudy'}</Text></View><Feather name="cloud" size={64} color="#F0B44A" /></View><View style={styles.metrics}><Metric icon="cloud-rain" value={`${weather.rain}%`} label={te ? 'వర్షం' : 'Rain'} /><Metric icon="droplet" value={`${weather.humidity}%`} label={te ? 'తేమ' : 'Humidity'} /><Metric icon="wind" value={`${weather.wind}`} label={te ? 'కి.మీ/గం' : 'km/h wind'} /></View><View style={styles.alert}><View style={styles.alertIcon}><Feather name="alert-triangle" size={19} color={colors.warning} /></View><View style={{ flex: 1, gap: 7 }}><Text style={styles.alertTitle}>{te ? 'పంట సూచన' : 'Crop alert'}</Text><Text style={styles.alertText}>{alert}</Text></View><VoiceButton language={language} text={alert} compact /></View><Text style={styles.forecastTitle}>{te ? '3 రోజుల అంచనా' : '3-day forecast'}</Text><View style={styles.forecast}>{weather.highs.map((high, index) => <View key={`${high}-${index}`} style={styles.day}><Text style={styles.dayName}>{index === 0 ? (te ? 'ఈ రోజు' : 'Today') : index === 1 ? (te ? 'రేపు' : 'Tomorrow') : (te ? 'ఎల్లుండి' : 'Day 3')}</Text><Feather name="cloud" size={23} color="#E9AE3B" /><Text style={styles.dayTemp}>{high}° / {weather.lows[index]}°</Text><Text style={styles.dayRain}>{weather.rainDays[index]}% rain</Text></View>)}</View><InfoBanner>{te ? 'స్థానం అనుమతి ఇవ్వకపోతే వాతావరణం గుంటూరు ఆధారంగా చూపిస్తాం.' : 'If location access is denied, weather uses Guntur as a fallback.'}</InfoBanner></Screen>;
}

function Metric({ icon, value, label }: { icon: keyof typeof Feather.glyphMap; value: string; label: string }) {
  return <View style={styles.metric}><Feather name={icon} size={19} color={colors.primary} /><Text style={styles.metricValue}>{value}</Text><Text style={styles.metricLabel}>{label}</Text></View>;
}

const styles = StyleSheet.create({
  refresh: { width: 42, height: 42, borderRadius: 21, backgroundColor: colors.secondary, alignItems: 'center', justifyContent: 'center' },
  current: { borderRadius: 25, padding: 24, backgroundColor: colors.sky, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  currentTemp: { color: colors.deep, fontSize: 57, fontWeight: '900' },
  condition: { color: colors.text, fontSize: 16 },
  metrics: { flexDirection: 'row', gap: 10 },
  metric: { flex: 1, minHeight: 88, borderRadius: 18, padding: 13, backgroundColor: colors.card, borderWidth: 1, borderColor: colors.border, gap: 5 },
  metricValue: { color: colors.deep, fontSize: 21, fontWeight: '900' },
  metricLabel: { color: colors.mutedForeground, fontSize: 12 },
  alert: { borderRadius: 20, padding: 15, backgroundColor: '#FFF3D9', flexDirection: 'row', alignItems: 'center', gap: 10 },
  alertIcon: { width: 40, height: 40, borderRadius: 14, backgroundColor: '#FFE2A2', alignItems: 'center', justifyContent: 'center' },
  alertTitle: { color: colors.warning, fontWeight: '900', fontSize: 15 },
  alertText: { color: colors.text, fontSize: 14, lineHeight: 20 },
  forecastTitle: { color: colors.deep, fontSize: 19, fontWeight: '900' },
  forecast: { flexDirection: 'row', gap: 9 },
  day: { flex: 1, alignItems: 'center', gap: 8, padding: 12, borderRadius: 17, backgroundColor: colors.card, borderWidth: 1, borderColor: colors.border },
  dayName: { color: colors.mutedForeground, fontSize: 12, fontWeight: '800' },
  dayTemp: { color: colors.deep, fontWeight: '900', fontSize: 14 },
  dayRain: { color: colors.primary, fontSize: 11 },
});