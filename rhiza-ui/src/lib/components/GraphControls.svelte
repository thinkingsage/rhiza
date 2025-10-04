<script>
  import { FILTER_CATEGORIES, FILTER_FREQUENCIES } from '../constants.js';
  
  export let selectedCategories;
  export let selectedFrequencies;
  export let educationalMode;
  export let onCategoryToggle;
  export let onFrequencyToggle;
  export let onEducationalModeToggle;
  export let onClearFilters;
</script>

<div class="filter-controls">
  <div class="filter-section">
    <h4>Categories</h4>
    <div class="filter-buttons">
      {#each FILTER_CATEGORIES as category}
        <button 
          class="filter-btn {selectedCategories.has(category) ? 'active' : ''}"
          on:click={() => onCategoryToggle(category)}
        >
          {category.replace('_', ' ')}
        </button>
      {/each}
    </div>
  </div>
  
  <div class="filter-section">
    <h4>Frequency</h4>
    <div class="filter-buttons">
      {#each FILTER_FREQUENCIES as frequency}
        <button 
          class="filter-btn {selectedFrequencies.has(frequency) ? 'active' : ''}"
          on:click={() => onFrequencyToggle(frequency)}
        >
          {frequency.replace('_', ' ')}
        </button>
      {/each}
    </div>
  </div>
  
  <button class="clear-filters-btn" on:click={onClearFilters}>Clear All Filters</button>
  
  <div class="educational-modes">
    <h4>Educational Modes</h4>
    <div class="mode-buttons">
      <button 
        class="mode-btn {educationalMode === 'category' ? 'active' : ''}"
        on:click={() => onEducationalModeToggle('category')}
      >
        Category Explorer
      </button>
      <button 
        class="mode-btn {educationalMode === 'grammar' ? 'active' : ''}"
        on:click={() => onEducationalModeToggle('grammar')}
      >
        Grammar Guide
      </button>
    </div>
  </div>
</div>


