#!/usr/bin/env node

/**
 * Stopwords-Based NER Implementation
 *
 * This implementation identifies potential entities by splitting text into tokens
 * and using a technical stopword list to determine the boundaries between them.
 * It is designed to preserve entities that contain punctuation, such as version
 * numbers, filenames, and URLs.
 */

const fs = require('fs');
const path = require('path');
const technicalStopwords = require('./technical-stopwords.js');

// --- Entity Categorization Patterns ---

// Using Sets for maintainability and creating regexes dynamically.
const technologyKeywords = new Set([
    'react', 'node', 'angular', 'vue', 'express', 'django', 'flask', 'spring', 'laravel', 'rails', 'asp', 'dotnet',
    'java', 'python', 'javascript', 'typescript', 'php', 'ruby', 'go', 'rust', 'swift', 'kotlin', 'scala', 'c\\+\\+', 'c#',
    '\\.net', 'mysql', 'postgresql', 'mongodb', 'redis', 'docker', 'kubernetes', 'aws', 'azure', 'gcp', 'git', 'github',
    'gitlab', 'npm', 'yarn', 'webpack', 'babel', 'eslint', 'jest', 'cypress', 'mocha', 'chai', 'selenium', 'jenkins',
    'travis', 'circleci'
]);

const organizationKeywords = new Set(['corp', 'inc', 'ltd', 'llc', 'company', 'organization', 'university', 'college', 'institute']);

// Regexes are now correct and more robust.
const patterns = {
    version: /\bv?\d+(\.\d+)+[a-zA-Z0-9-]*\b/i,
    email: /\S+@\S+\.\S+/,
    url: /^(https?:\/\/|www\.)\S+/i,
    fileName: /\.(js|ts|jsx|tsx|json|xml|html|css|md|txt|py|java|cpp|c|h|hpp|sql|yaml|yml|toml|ini|cfg|conf|env)$/i,
    path: /[/\\]/,
    date: {
        numeric: /\d{1,2}[/-]\d{1,2}[/-]\d{2,4}/,
        text: /(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/i
    },
    person: /^[A-Z][a-z]+(\s+[A-Z][a-z]+)*$/,
    technology: new RegExp(`\\b(${[...technologyKeywords].join('|')})\\b`, 'i'),
    // This regex now correctly looks for org keywords at the end of a token.
    organization: new RegExp(`(${[...organizationKeywords].join('|')})$`, 'i')
};

/**
 * Extracts entities using a stopwords-based approach without destroying the original text.
 * @param {string} text - Input text to process.
 * @returns {Array<string>} - Array of extracted, unique entities.
 */
function extractEntitiesWithStopwords(text) {
    // Normalize multiple whitespace characters to a single space.
    const normalizedText = text.replace(/\s+/g, ' ');
    const tokens = normalizedText.split(' ');

    const entities = [];
    let currentEntity = '';

    for (const token of tokens) {
        if (!token) continue;

        // Clean the token for stopword checking, but preserve the original token.
        // This removes common trailing punctuation to correctly identify stopwords.
        const cleanToken = token.replace(/[.,;:]+$/, '');

        if (technicalStopwords.has(cleanToken.toLowerCase())) {
            // If we have an accumulated entity, save it.
            if (currentEntity) {
                entities.push(currentEntity);
                currentEntity = '';
            }
        } else {
            // If the token is a standalone entity type (like a version),
            // commit the previous entity and treat this token as a new one.
            // This correctly splits "React 16.8" into "React" and "16.8".
            if (patterns.version.test(token) && currentEntity) {
                entities.push(currentEntity);
                currentEntity = token;
            } else {
                // Accumulate non-stopwords, preserving original token.
                currentEntity = currentEntity ? `${currentEntity} ${token}` : token;
            }
        }
    }

    // Add the last entity if the text doesn't end with a stopword.
    if (currentEntity) {
        entities.push(currentEntity);
    }

    // Post-process to filter out meaningless entities and remove duplicates.
    const filteredEntities = entities
        .map(e => e.trim().replace(/^[.,;:]+|[.,;:]+$/g, '')) // Trim and clean leading/trailing punctuation
        .filter(e => e.length > 1 && !isMeaninglessInteger(e));

    return [...new Set(filteredEntities)];
}

/**
 * Checks if a string is a simple integer, which is often not a meaningful entity.
 * @param {string} str - String to check.
 * @returns {boolean} - True if it's just an integer.
 */
function isMeaninglessInteger(str) {
    // Correctly checks if the string contains only digits.
    return /^\d+$/.test(str);
}

/**
 * Categorizes entities based on a set of predefined patterns.
 * @param {Array<string>} entities - Array of entity strings.
 * @returns {Object} - An object with categorized entities.
 */
function categorizeEntities(entities) {
    const categorized = {
        people: [],
        organizations: [],
        technologies: [],
        versions: [],
        fileNames: [],
        paths: [],
        emails: [],
        urls: [],
        dates: [],
        other: []
    };

    entities.forEach(entity => {
        const lowerEntity = entity.toLowerCase();

        // The order of checks is critical. More specific patterns should come first.
        if (patterns.email.test(entity)) {
            categorized.emails.push(entity);
        } else if (patterns.url.test(entity)) {
            categorized.urls.push(entity);
        } else if (patterns.version.test(entity)) {
            categorized.versions.push(entity);
        } else if (patterns.date.numeric.test(entity) || patterns.date.text.test(entity)) {
            categorized.dates.push(entity);
        } else if (patterns.technology.test(entity)) {
            categorized.technologies.push(entity);
        } else if (patterns.path.test(entity)) {
            // Path is checked after technology to avoid miscategorizing things like "Node.js/something"
            categorized.paths.push(entity);
        } else if (patterns.fileName.test(lowerEntity)) {
            categorized.fileNames.push(entity);
        } else if (patterns.organization.test(entity)) {
            categorized.organizations.push(entity);
        } else if (patterns.person.test(entity) && entity.length > 2 && entity.length < 30) {
            // This is a heuristic. We check it's not a known technology first.
            if (!technologyKeywords.has(lowerEntity)) {
                categorized.people.push(entity);
            } else {
                // Already categorized as technology, so this is just a fallback.
                categorized.other.push(entity);
            }
        } else {
            categorized.other.push(entity);
        }
    });

    return categorized;
}

/**
 * Processes a string of text to extract and categorize named entities.
 * @param {string} text - Input text.
 * @returns {Object} - An object with raw and categorized entities.
 */
function processText(text) {
    const entities = extractEntitiesWithStopwords(text);
    const categorized = categorizeEntities(entities);

    return {
        rawEntities: entities,
        categorizedEntities: categorized,
        totalEntities: entities.length
    };
}

// Export functions for use in other modules.
module.exports = {
    extractEntitiesWithStopwords,
    categorizeEntities,
    processText
};

// --- Command-Line Interface ---

/**
 * Prints the results of the NER processing to the console.
 * @param {Object} result - The result object from processText.
 */
function printResults(result) {
    console.log('Raw Entities:');
    result.rawEntities.forEach((entity, index) => {
        console.log(`  ${index + 1}. ${entity}`);
    });

    console.log('\nCategorized Entities:');
    Object.entries(result.categorizedEntities).forEach(([category, entities]) => {
        if (entities.length > 0) {
            // Capitalize category for display
            const capitalizedCategory = category.charAt(0).toUpperCase() + category.slice(1);
            console.log(`  ${capitalizedCategory}:`);
            entities.forEach(entity => {
                console.log(`    - ${entity}`);
            });
        }
    });

    console.log(`\nTotal Entities Found: ${result.totalEntities}`);
}

// If run directly as a script, process sample text.
if (require.main === module) {
    // Correctly handle command-line arguments.
    if (process.argv.includes('--test')) {
        runTests();
    } else {
        // Sample text demonstrates the script's capabilities.
        const sampleText = "John Doe works at OpenSourceCorp. He uses React 16.8 and Node.js to build web applications. The project version is v2.1.0. You can reach him at john.doe@opensourcecorp.com or visit https://github.com/johndoe/project. The main file is app.js and config is in /etc/project/config.json.";

        console.log('=== Stopwords-Based NER Test ===\n');
        console.log(`Input Text: ${sampleText}\n`);

        const result = processText(sampleText);
        printResults(result);

        console.log('\n🎉 Stopwords-Based NER Processing Complete!');
    }
}

// Test function for validation.
function runTests() {
    const testCases = [
        {
            name: 'Basic Technical Text',
            text: 'John Doe works at OpenSourceCorp. He uses React 16.8 and Node.js to build web applications. The project version is 2.1.0.',
            expected: {
                people: ['John Doe'],
                organizations: ['OpenSourceCorp'],
                technologies: ['React', 'Node.js'],
                versions: ['16.8', '2.1.0']
            }
        },
        {
            name: 'File Paths and Extensions',
            text: 'The main file is app.js and config is in /etc/project/config.json. Also check README.md and package.json.',
            expected: {
                fileNames: ['app.js', 'README.md', 'package.json'],
                paths: ['/etc/project/config.json']
            }
        },
        {
            name: 'Emails and URLs',
            text: 'Contact us at support@example.com or visit https://www.example.com for more information.',
            expected: {
                emails: ['support@example.com'],
                urls: ['https://www.example.com']
            }
        },
        {
            name: 'Dates and Versions',
            text: 'The software was released on 01/15/2025. Version v3.2.1 includes new features.',
            expected: {
                dates: ['01/15/2025'],
                versions: ['v3.2.1']
            }
        }
    ];

    console.log('\n=== Test Cases ===\n');
    let testsPassed = 0;

    testCases.forEach((testCase, index) => {
        console.log(`--- Test Case ${index + 1}: ${testCase.name} ---`);
        console.log(`Input: ${testCase.text}`);

        const result = processText(testCase.text);
        let allExpectedFound = true;

        console.log('Result:');
        Object.entries(testCase.expected).forEach(([category, expectedEntities]) => {
            const foundEntities = result.categorizedEntities[category] || [];
            const missing = expectedEntities.filter(e => !foundEntities.includes(e));

            if (missing.length > 0) {
                allExpectedFound = false;
                console.log(`  [FAIL] In ${category}, missing: ${missing.join(', ')}`);
            } else {
                console.log(`  [PASS] Category '${category}' correct.`);
            }
        });

        if (allExpectedFound) {
            testsPassed++;
            console.log('Status: PASSED\n');
        } else {
            console.log('Status: FAILED\n');
        }
    });

    console.log(`--- Summary ---`);
    console.log(`${testsPassed} out of ${testCases.length} tests passed.`);
    if (testsPassed === testCases.length) {
        console.log('✅ All tests passed!');
    } else {
        console.log('❌ Some tests failed.');
    }
}
