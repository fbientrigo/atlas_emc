import mermaid from 'mermaid';

// Mantener los diagramas legibles en ambos temas, sin filtros que inviertan colores.
const palettes = {
  light: {
    primaryColor:'#f2fafe', primaryTextColor:'#1d2228', primaryBorderColor:'#737a82',
    lineColor:'#5e656f', secondaryColor:'#fff', tertiaryColor:'#fefefe',
    background:'#fefefe', textColor:'#1d2228', edgeLabelBackground:'#fff',
    clusterBkg:'#f6f7f8', clusterBorder:'#aeb6bc', noteBkgColor:'#fffbef',
    noteTextColor:'#1d2228', noteBorderColor:'#b69450'
  },
  dark: {
    primaryColor:'#172c3b', primaryTextColor:'#e8edf5', primaryBorderColor:'#7a8899',
    lineColor:'#a8b4c2', secondaryColor:'#151d27', tertiaryColor:'#0c1118',
    background:'#0c1118', textColor:'#e8edf5', edgeLabelBackground:'#151d27',
    clusterBkg:'#202a35', clusterBorder:'#6a7a8e', noteBkgColor:'#302519',
    noteTextColor:'#e8edf5', noteBorderColor:'#d8b06e'
  }
};
function setTheme(theme) {
  mermaid.initialize({
    startOnLoad: false, securityLevel: 'strict', theme: 'base',
    fontFamily: 'ui-monospace, monospace',
    themeVariables: palettes[theme === 'dark' ? 'dark' : 'light'],
    flowchart: {htmlLabels:false, useMaxWidth:true},
    sequence: {useMaxWidth:true}
  });
}
setTheme(document.documentElement.dataset.theme);
window.AtlasMermaid = mermaid;
window.AtlasMermaidSetTheme = setTheme;
