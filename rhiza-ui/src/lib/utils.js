// API utilities
export async function searchWord(word, apiBaseUrl) {
  const response = await fetch(`${apiBaseUrl}/word/${word.trim()}`);
  
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    const errorMsg = errorData.detail || `Server error (${response.status})`;
    throw new Error(errorMsg);
  }
  
  return await response.json();
}

export async function fetchGraphData(word, apiBaseUrl) {
  const response = await fetch(`${apiBaseUrl}/word/${word}/graph`);
  return await response.json();
}

// Filter utilities
export function toggleSetItem(set, item) {
  if (set.has(item)) {
    set.delete(item);
  } else {
    set.add(item);
  }
  return new Set(set); // Return new Set to trigger reactivity
}

export function clearSet(set) {
  set.clear();
  return new Set(set); // Return new Set to trigger reactivity
}
