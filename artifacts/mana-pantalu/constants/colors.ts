/**
 * Semantic design tokens for the mobile app.
 *
 * These tokens mirror the naming conventions used in web artifacts (index.css)
 * so that multi-artifact projects share a cohesive visual identity.
 *
 * Replace the placeholder values below with values that match the project's
 * brand. If a sibling web artifact exists, read its index.css and convert the
 * HSL values to hex so both artifacts use the same palette.
 *
 * To add dark mode, add a `dark` key with the same token names.
 * The useColors() hook will automatically pick it up.
 */

const palette = {
    text: '#183126',
    tint: '#2E6B3A',
    background: '#F6FBF4',
    foreground: '#183126',
    card: '#FFFFFF',
    cardForeground: '#183126',
    primary: '#2E6B3A',
    primaryForeground: '#FFFFFF',
    secondary: '#E3F0E2',
    secondaryForeground: '#1F4D2A',
    muted: '#EAF4E7',
    mutedForeground: '#637369',
    accent: '#F5B942',
    accentForeground: '#4A3200',
    destructive: '#B3261E',
    destructiveForeground: '#FFFFFF',
    border: '#D5E4D3',
    input: '#C6D9C5',
    warning: '#C77700',
    success: '#4F8A54',
    deep: '#1F4D2A',
    soft: '#EDF7EB',
    sky: '#DCEFF4',
    ink: '#183126',
};

const colors = {
  light: palette,
  ...palette,
  radius: 18,
};

export default colors;
