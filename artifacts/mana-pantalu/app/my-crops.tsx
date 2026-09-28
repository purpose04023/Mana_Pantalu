import React from 'react';
import { router } from 'expo-router';
import CropsScreen from './(tabs)/crops';

export default function MyCropsRoute() {
  React.useEffect(() => {
    // The tab screen is shared intentionally; this route keeps the Home tile deep linkable.
  }, []);
  return <CropsScreen />;
}