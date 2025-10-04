<script>
  import { fade } from 'svelte/transition';
  import SearchResults from '$lib/components/SearchResults.svelte';
  import GraphVisualization from '$lib/components/GraphVisualization.svelte';
  import { searchWord, fetchGraphData, toggleSetItem, clearSet } from '$lib/utils.js';
  
  let wordToSearch = '';
  let isLoading = false;
  let searchResult = null;
  let errorMessage = null;
  let showGraphViz = false;
  let graphData = null;
  let selectedCategories = new Set();
  let selectedFrequencies = new Set();
  let educationalMode = null;
  let showRelatedWords = false;

  const API_BASE_URL = '/api';

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
      const url = `${API_BASE_URL}/word/${word}/graph${showRelatedWords ? '?include_related=true' : ''}`;
      const response = await fetch(url);
      const data = await response.json();
      
      if (data.nodes.length > 0) {
        graphData = data;
        showGraphViz = true;
      }
    } catch (error) {
      console.error('Failed to fetch graph data:', error);
    }
  }

  function handleKeyPress(event) {
    if (event.key === 'Enter') {
      searchForRoot();
    }
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
      <div class="search-options">
        <label class="checkbox-label">
          <input type="checkbox" bind:checked={showRelatedWords} />
          Show related words
        </label>
      </div>
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
        onClose={closeGraph}
      />
    {/if}

    {#if errorMessage}
      <p class="error">{errorMessage}</p>
    {/if}
  </div>
</main>


