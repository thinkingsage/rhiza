<script>
  import { fade } from 'svelte/transition';
  import SearchResults from '$lib/components/SearchResults.svelte';
  import GraphVisualization from '$lib/components/GraphVisualization.svelte';
  import { searchWord, fetchGraphData, toggleSetItem, clearSet } from '$lib/utils.js';
  
  // State
  let wordToSearch = '';
  let isLoading = false;
  let searchResult = null;
  let errorMessage = null;
  let showGraphViz = false;
  let graphData = null;
  let selectedCategories = new Set();
  let selectedFrequencies = new Set();
  let educationalMode = null;

  const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

  // Search functionality
  async function searchForRoot() {
    if (!wordToSearch.trim()) return;

    isLoading = true;
    searchResult = null;
    errorMessage = null;
    showGraphViz = false;

    try {
      searchResult = await searchWord(wordToSearch, API_BASE_URL);
      
      if (searchResult.roots.length > 0) {
        const data = await fetchGraphData(searchResult.name, API_BASE_URL);
        if (data.nodes.length > 0) {
          graphData = data;
          showGraphViz = true;
        }
      }
    } catch (error) {
      console.error('Search error:', error);
      errorMessage = error.message || 'An error occurred while searching. Please try again.';
    } finally {
      isLoading = false;
    }
  }

  async function showGraph(word) {
    try {
      const data = await fetchGraphData(word, API_BASE_URL);
      if (data.nodes.length > 0) {
        graphData = data;
        showGraphViz = true;
      }
    } catch (error) {
      console.error('Failed to fetch graph data:', error);
    }
  }

  // Event handlers
  function handleKeyPress(event) {
    if (event.key === 'Enter') {
      searchForRoot();
    }
  }

  function toggleCategoryFilter(category) {
    selectedCategories = toggleSetItem(selectedCategories, category);
  }

  function toggleFrequencyFilter(frequency) {
    selectedFrequencies = toggleSetItem(selectedFrequencies, frequency);
  }

  function clearFilters() {
    selectedCategories = clearSet(selectedCategories);
    selectedFrequencies = clearSet(selectedFrequencies);
  }

  function toggleEducationalMode(mode) {
    educationalMode = educationalMode === mode ? null : mode;
  }

  function closeGraph() {
    showGraphViz = false;
  }
</script>

<main>
  <div class="card">
    <h1>ῥίζα</h1>
    <p class="subtitle">Explore the Greek roots of the English language.</p>

    <div class="search-container">
      <input
        type="text"
        bind:value={wordToSearch}
        on:keypress={handleKeyPress}
        placeholder="Enter an English word (e.g., philosophy, democracy)"
        class="search-input"
        disabled={isLoading}
      />
      <button on:click={searchForRoot} class="search-btn" disabled={isLoading || !wordToSearch.trim()}>
        {#if isLoading}
          Searching...
        {:else}
          Search
        {/if}
      </button>
    </div>

    <SearchResults 
      {searchResult} 
      {showGraphViz} 
      onShowGraph={showGraph} 
    />

    {#if showGraphViz && graphData}
      <GraphVisualization 
        {graphData}
        {educationalMode}
        {selectedCategories}
        {selectedFrequencies}
        onClose={closeGraph}
        onCategoryToggle={toggleCategoryFilter}
        onFrequencyToggle={toggleFrequencyFilter}
        onEducationalModeToggle={toggleEducationalMode}
        onClearFilters={clearFilters}
      />
    {/if}

    {#if errorMessage}
      <p class="error">{errorMessage}</p>
    {/if}
  </div>
</main>


