<script>
  import { fade } from 'svelte/transition';
  
  export let searchResult;
  export let showGraphViz;
  export let onShowGraph;
</script>

{#if searchResult && searchResult.roots.length > 0}
  <div class="result" transition:fade={{ duration: 600 }}>
    <h2>{searchResult.name}</h2>
    <p class="roots-intro">Greek roots:</p>
    <ul class="roots-list">
      {#each searchResult.roots as root}
        <li class="root-item">
          <div class="root-main">
            <strong class="greek-text">{root.name}</strong> 
            <span class="root-transliteration">({root.transliteration})</span>:
            <span class="root-meaning">{root.meaning}</span>
          </div>
          {#if root.category || root.frequency || root.part_of_speech}
            <div class="root-details">
              {#if root.category}
                <span class="root-tag category">{root.category}</span>
              {/if}
              {#if root.frequency}
                <span class="root-tag frequency">{root.frequency} frequency</span>
              {/if}
              {#if root.part_of_speech}
                <span class="root-tag pos">{root.part_of_speech}</span>
              {/if}
            </div>
          {/if}
        </li>
      {/each}
    </ul>
    {#if !showGraphViz}
      <button class="graph-btn" on:click={() => onShowGraph(searchResult.name)}>
        View Graph
      </button>
    {/if}
  </div>
{:else if searchResult && searchResult.roots.length === 0}
  <div class="result no-roots" transition:fade={{ duration: 600 }}>
    <h2>{searchResult.name}</h2>
    <p class="no-roots-message">No Greek roots found for this word.</p>
  </div>
{/if}


