import { y as bind_props, z as ensure_array_like, F as attr } from "../../chunks/index.js";
import { e as escape_html } from "../../chunks/context.js";
import "d3";
function SearchResults($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    let searchResult = $$props["searchResult"];
    let showGraphViz = $$props["showGraphViz"];
    let onShowGraph = $$props["onShowGraph"];
    if (searchResult && searchResult.roots.length > 0) {
      $$renderer2.push("<!--[-->");
      $$renderer2.push(`<div class="result"><h2>${escape_html(searchResult.name)}</h2> <p class="roots-intro">Greek roots:</p> <ul class="roots-list"><!--[-->`);
      const each_array = ensure_array_like(searchResult.roots);
      for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
        let root = each_array[$$index];
        $$renderer2.push(`<li class="root-item"><div class="root-main"><strong class="greek-text">${escape_html(root.name)}</strong> <span class="root-transliteration">(${escape_html(root.transliteration)})</span>: <span class="root-meaning">${escape_html(root.meaning)}</span></div> `);
        if (root.category || root.frequency || root.part_of_speech) {
          $$renderer2.push("<!--[-->");
          $$renderer2.push(`<div class="root-details">`);
          if (root.category) {
            $$renderer2.push("<!--[-->");
            $$renderer2.push(`<span class="root-tag category">${escape_html(root.category)}</span>`);
          } else {
            $$renderer2.push("<!--[!-->");
          }
          $$renderer2.push(`<!--]--> `);
          if (root.frequency) {
            $$renderer2.push("<!--[-->");
            $$renderer2.push(`<span class="root-tag frequency">${escape_html(root.frequency)} frequency</span>`);
          } else {
            $$renderer2.push("<!--[!-->");
          }
          $$renderer2.push(`<!--]--> `);
          if (root.part_of_speech) {
            $$renderer2.push("<!--[-->");
            $$renderer2.push(`<span class="root-tag pos">${escape_html(root.part_of_speech)}</span>`);
          } else {
            $$renderer2.push("<!--[!-->");
          }
          $$renderer2.push(`<!--]--></div>`);
        } else {
          $$renderer2.push("<!--[!-->");
        }
        $$renderer2.push(`<!--]--></li>`);
      }
      $$renderer2.push(`<!--]--></ul> `);
      if (!showGraphViz) {
        $$renderer2.push("<!--[-->");
        $$renderer2.push(`<button class="graph-btn">View Graph</button>`);
      } else {
        $$renderer2.push("<!--[!-->");
      }
      $$renderer2.push(`<!--]--></div>`);
    } else {
      $$renderer2.push("<!--[!-->");
      if (searchResult && searchResult.roots.length === 0) {
        $$renderer2.push("<!--[-->");
        $$renderer2.push(`<div class="result no-roots"><h2>${escape_html(searchResult.name)}</h2> <p class="no-roots-message">No Greek roots found for this word.</p></div>`);
      } else {
        $$renderer2.push("<!--[!-->");
      }
      $$renderer2.push(`<!--]-->`);
    }
    $$renderer2.push(`<!--]-->`);
    bind_props($$props, { searchResult, showGraphViz, onShowGraph });
  });
}
function GraphVisualization($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    let graphData = $$props["graphData"];
    let onClose = $$props["onClose"];
    $$renderer2.push(`<div style="margin-top: 2rem; padding: 1.5rem; background: rgba(255,255,255,0.95); border-radius: 12px; box-shadow: 0 8px 32px rgba(0,0,0,0.1); max-width: 100%; overflow: hidden;"><div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;"><h3 style="margin: 0;">Etymology Graph</h3> <button class="search-btn" style="padding: 0.5rem; min-width: auto;">×</button></div> <div style="width: 100%; max-width: 100%; overflow: hidden;"></div></div>`);
    bind_props($$props, { graphData, onClose });
  });
}
function _page($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    let wordToSearch = "";
    let isLoading = false;
    let searchResult = null;
    let showGraphViz = false;
    let graphData = null;
    let showRelatedWords = false;
    const API_BASE_URL = "/api";
    async function showGraph(word) {
      try {
        const url = `${API_BASE_URL}/word/${word}/graph${showRelatedWords ? "?include_related=true" : ""}`;
        const response = await fetch(url);
        const data = await response.json();
        if (data.nodes.length > 0) {
          graphData = data;
          showGraphViz = true;
        }
      } catch (error) {
        console.error("Failed to fetch graph data:", error);
      }
    }
    function closeGraph() {
      showGraphViz = false;
    }
    $$renderer2.push(`<main><div class="card"><h1>ῥίζα</h1> <p class="subtitle">Explore the Greek roots of the English language.</p> <div class="search-container"><input type="text"${attr("value", wordToSearch)} placeholder="Enter an English word (e.g., philosophy, democracy)" class="search-input"${attr("disabled", isLoading, true)}/> <div class="search-options"><label class="checkbox-label"><input type="checkbox"${attr("checked", showRelatedWords, true)}/> Show related words</label></div> <button class="search-btn"${attr("disabled", !wordToSearch.trim(), true)}>`);
    {
      $$renderer2.push("<!--[!-->");
      $$renderer2.push(`Search`);
    }
    $$renderer2.push(`<!--]--></button></div> `);
    SearchResults($$renderer2, { searchResult, showGraphViz, onShowGraph: showGraph });
    $$renderer2.push(`<!----> `);
    if (showGraphViz && graphData) {
      $$renderer2.push("<!--[-->");
      GraphVisualization($$renderer2, { graphData, onClose: closeGraph });
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--> `);
    {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--></div></main>`);
  });
}
export {
  _page as default
};
