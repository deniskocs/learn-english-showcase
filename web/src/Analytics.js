const ANALYTICS_ID = import.meta.env.VITE_GA_ID;

export function setUserId(userToken) {
  if (!userToken) return;

  try {
    const payload = JSON.parse(atob(userToken.split('.')[1]));
    const userId = payload.uid; // uid из JWT
    gtag('set', { user_id: userId });
  } catch (e) {
    console.warn('Failed to init analytics:', e);
  }
}

export function clearUserId() {
    gtag('config', ANALYTICS_ID, { user_id: null });
}
export function track(eventName, params = {}) {
  if (typeof gtag !== 'function') return;
  gtag('event', eventName, params);
}