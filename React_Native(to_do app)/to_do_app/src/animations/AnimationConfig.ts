import { Easing } from "react-native"

export const AnimationConfig = {
  // Screen transitions
  screenTransition: {
    duration: 300,
    easing: Easing.out(Easing.cubic),
  },

  // Modal transitions
  modalTransition: {
    duration: 250,
    easing: Easing.out(Easing.quad),
  },

  // Micro-interactions
  buttonPress: {
    duration: 150,
    easing: Easing.out(Easing.quad),
  },

  // List animations
  listItem: {
    duration: 200,
    easing: Easing.out(Easing.quad),
    stagger: 50,
  },

  // Progress animations
  progress: {
    duration: 800,
    easing: Easing.out(Easing.cubic),
  },

  // Floating action button
  fab: {
    duration: 200,
    easing: Easing.out(Easing.back(1.2)),
  },

  // Card animations
  card: {
    duration: 300,
    easing: Easing.out(Easing.cubic),
  },

  // Spring animations
  spring: {
    tension: 100,
    friction: 8,
  },
}

export const AnimationPresets = {
  fadeIn: {
    from: { opacity: 0 },
    to: { opacity: 1 },
  },

  fadeOut: {
    from: { opacity: 1 },
    to: { opacity: 0 },
  },

  slideInUp: {
    from: { opacity: 0, translateY: 50 },
    to: { opacity: 1, translateY: 0 },
  },

  slideInDown: {
    from: { opacity: 0, translateY: -50 },
    to: { opacity: 1, translateY: 0 },
  },

  slideInLeft: {
    from: { opacity: 0, translateX: -50 },
    to: { opacity: 1, translateX: 0 },
  },

  slideInRight: {
    from: { opacity: 0, translateX: 50 },
    to: { opacity: 1, translateX: 0 },
  },

  scaleIn: {
    from: { opacity: 0, scale: 0.8 },
    to: { opacity: 1, scale: 1 },
  },

  scaleOut: {
    from: { opacity: 1, scale: 1 },
    to: { opacity: 0, scale: 0.8 },
  },

  bounce: {
    from: { scale: 1 },
    to: { scale: 1.1 },
  },
}
