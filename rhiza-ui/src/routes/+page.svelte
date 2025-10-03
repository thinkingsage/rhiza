<script>
  // This block contains our JavaScript logic
  let wordToSearch = '';
  let isLoading = false;
  let searchResult = null;
  let errorMessage = null;

  async function searchForRoot() {
    if (!wordToSearch.trim()) return;

    isLoading = true;
    searchResult = null;
    errorMessage = null;

    try {
      // Calls our FastAPI backend. Make sure the backend server is running!
      // In a real app, the URL would be in an environment variable.
      const response = await fetch(`http://127.0.0.1:8000/word/${wordToSearch.trim()}`);

      if (!response.ok) {
        throw new Error(`An error occurred: ${response.statusText}`);
      }

      searchResult = await response.json();
    } catch (error) {
      errorMessage = error.message;
      console.error('Failed to fetch word roots:', error);
    } finally {
      isLoading = false;
    }
  }
</script>

<main>
  <div class="card">
    <h1>Rhiza ῥίζα</h1>
    <p>Explore the Greek roots of the English language.</p>

    <div class="search-container">
      <input
        type="text"
        bind:value={wordToSearch}
        placeholder="Enter a word (e.g., philosophy)"
        on:keydown={(e) => e.key === 'Enter' && searchForRoot()}
      />
      <button on:click={searchForRoot} disabled={isLoading}>
        {isLoading ? 'Searching...' : 'Search'}
      </button>
    </div>

    {#if searchResult}
      <div class="result">
        <h2>{searchResult.name}</h2>
        {#if searchResult.roots.length > 0}
          <ul>
            {#each searchResult.roots as root}
              <li>
                <strong>{root.name}</strong> ({root.transliteration}):
                <span>{root.meaning}</span>
              </li>
            {/each}
          </ul>
        {:else}
          <p>No Greek roots found for this word.</p>
        {/if}
      </div>
    {/if}

    {#if errorMessage}
        <p class="error">{errorMessage}</p>
    {/if}
  </div>
</main>

<style>
  /* This block contains our CSS styling */
  main {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    display: flex;
    justify-content: center;
    align-items: flex-start;
    padding-top: 5rem;
    height: 100vh;
    background-color: #f4f4f9;
  }

  .card {
    background: white;
    padding: 2rem;
    border-radius: 10px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    width: 100%;
    max-width: 500px;
    text-align: center;
  }

  h1 {
    color: #333;
    font-weight: 600;
  }

  p {
    color: #666;
    margin-bottom: 2rem;
  }

  .search-container {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 1.5rem;
  }

  input {
    flex-grow: 1;
    padding: 0.75rem;
    border: 1px solid #ccc;
    border-radius: 5px;
    font-size: 1rem;
  }

  button {
    padding: 0.75rem 1.5rem;
    border: none;
    border-radius: 5px;
    background-color: #007bff;
    color: white;
    font-size: 1rem;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  button:hover {
    background-color: #0056b3;
  }

  button:disabled {
    background-color: #aaa;
    cursor: not-allowed;
  }
  
  .result {
    text-align: left;
    margin-top: 2rem;
  }

  .result h2 {
    text-transform: capitalize;
  }

  .result ul {
    list-style-type: none;
    padding: 0;
  }

  .result li {
    background-color: #f9f9f9;
    padding: 0.75rem;
    border: 1px solid #eee;
    border-radius: 5px;
    margin-bottom: 0.5rem;
  }
  
  .error {
    color: #d93025;
    margin-top: 1rem;
  }
</style>