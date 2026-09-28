import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { Language, Scan, Tip, UserCrop, initialCrops, initialScans } from '@/data/mockData';

type AppContextValue = {
  hydrated: boolean;
  language: Language;
  welcomeSeen: boolean;
  notifications: boolean;
  crops: UserCrop[];
  scans: Scan[];
  savedTips: string[];
  setLanguage: (language: Language) => void;
  completeWelcome: () => void;
  setNotifications: (enabled: boolean) => void;
  addCrop: (crop: UserCrop) => void;
  addScan: (scan: Scan) => void;
  saveTip: (tip: Tip) => void;
  isTipSaved: (tipId: string) => boolean;
  helpful: (scanId: string, value: boolean) => void;
};

const STORAGE_KEY = 'mana-pantalu-state-v1';
const AppContext = createContext<AppContextValue | null>(null);

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [hydrated, setHydrated] = useState(false);
  const [language, setLanguageState] = useState<Language>('te');
  const [welcomeSeen, setWelcomeSeen] = useState(false);
  const [notifications, setNotificationsState] = useState(true);
  const [crops, setCrops] = useState<UserCrop[]>(initialCrops);
  const [scans, setScans] = useState<Scan[]>(initialScans);
  const [savedTips, setSavedTips] = useState<string[]>([]);

  useEffect(() => {
    AsyncStorage.getItem(STORAGE_KEY)
      .then((raw) => {
        if (!raw) return;
        const saved = JSON.parse(raw) as Partial<AppContextValue>;
        if (saved.language === 'te' || saved.language === 'en') setLanguageState(saved.language);
        if (typeof saved.welcomeSeen === 'boolean') setWelcomeSeen(saved.welcomeSeen);
        if (typeof saved.notifications === 'boolean') setNotificationsState(saved.notifications);
        if (Array.isArray(saved.crops)) setCrops(saved.crops);
        if (Array.isArray(saved.scans)) setScans(saved.scans);
        if (Array.isArray(saved.savedTips)) setSavedTips(saved.savedTips);
      })
      .catch(() => undefined)
      .finally(() => setHydrated(true));
  }, []);

  useEffect(() => {
    if (!hydrated) return;
    AsyncStorage.setItem(STORAGE_KEY, JSON.stringify({ language, welcomeSeen, notifications, crops, scans, savedTips })).catch(() => undefined);
  }, [crops, hydrated, language, notifications, savedTips, scans, welcomeSeen]);

  const value = useMemo<AppContextValue>(() => ({
    hydrated,
    language,
    welcomeSeen,
    notifications,
    crops,
    scans,
    savedTips,
    setLanguage: setLanguageState,
    completeWelcome: () => setWelcomeSeen(true),
    setNotifications: setNotificationsState,
    addCrop: (crop) => setCrops((current) => [crop, ...current]),
    addScan: (scan) => setScans((current) => [scan, ...current]),
    saveTip: (tip) => setSavedTips((current) => current.includes(tip.id) ? current.filter((id) => id !== tip.id) : [...current, tip.id]),
    isTipSaved: (tipId) => savedTips.includes(tipId),
    helpful: (scanId, value) => setScans((current) => current.map((scan) => scan.id === scanId ? { ...scan, helpful: value } as Scan & { helpful: boolean } : scan)),
  }), [crops, hydrated, language, notifications, savedTips, scans, welcomeSeen]);

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp() {
  const value = useContext(AppContext);
  if (!value) throw new Error('useApp must be used inside AppProvider');
  return value;
}