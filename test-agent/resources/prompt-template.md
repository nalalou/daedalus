You are writing %%FRAMEWORK%% integration tests for a %%PROJECT_TYPE%% app. Write tests for the source file below.

RULES:
- Test chains of behavior, not isolated units. "This action → does this → which causes that."
%%MSW_RULE%%
%%MOCK_RULE%%
- No conditional logic in tests. Each test: setup → act → assert.
%%EXTRA_RULES%%

ASSERTION REQUIREMENTS (your tests will be automatically rejected if these are not met):
- EVERY test block (it/test) MUST have at least one SPECIFIC assertion: .toBe(), .toEqual(), .toContain(), .toMatch(), .toHaveBeenCalledWith(), .toHaveLength(), .toThrow(), .toStrictEqual(), .toMatchObject(), .toHaveProperty(), or status checks like .toBe(200).
- NEVER use .toBeDefined(), .toBeTruthy(), .toBeNull(), or .not.toBeNull() as the only assertion in a test block. These are too weak — they don't verify behavior.
- At least one test MUST cover an error or failure path (e.g., 401 unauthorized, 400 bad input, network failure, thrown error, rejected promise).
- If the source code has conditional logic (if/else, ternary, switch), write tests that exercise BOTH branches. A mutation in any branch condition should cause at least one test to fail.
- Prefer fewer, thorough tests over many shallow ones. 5 tests with strong assertions beat 10 tests with weak ones.

PATTERN TO USE: %%PATTERN%%

%%MSW_SETUP%%

SOURCE FILE TO TEST:
Path: %%SOURCE_PATH%%

%%SOURCE_CONTENT%%

%%EXEMPLAR_SECTION%%

OUTPUT:
Write ONLY the test file content. No explanation. No markdown fences. Just the TypeScript code.
The test file will be saved to: %%TEST_PATH%%
