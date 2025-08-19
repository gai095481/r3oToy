/**
 * A set of technical and common English stopwords for the NER tool.
 * These words are typically filtered out as they don't represent
 * meaningful entities themselves but act as separators.
 */
const technicalStopwords = new Set([
  'a', 'about', 'also', 'an', 'and', 'are', 'as', 'at', 'be', 'been', 'being',
  'but', 'by', 'can', 'check', 'config', 'contact', 'could', 'did', 'do',
  'does', 'each', 'etc', 'features', 'file', 'for', 'from', 'had', 'has',
  'have', 'he', 'her', 'him', 'his', 'how', 'i', 'if', 'in', 'includes',
  'information', 'is', 'it', 'its', 'main', 'more', 'new', 'not', 'of',
  'on', 'or', 'project', 'released', 'she', 'should', 'so', 'software',
  'some', 'such', 'team', 'that', 'the', 'their', 'they', 'this', 'to',
  'uses', 'version', 'visit', 'was', 'we', 'were', 'what', 'when', 'where',
  'which', 'who', 'will', 'with', 'works', 'would', 'you', 'your', 'using'
]);

module.exports = technicalStopwords;
