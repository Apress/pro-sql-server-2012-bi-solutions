-- Listing 6-19. An example of code that the Query Designer will change without your consent
SELECT au_id AS AuthorId, CAST( (au_fname + N' ' + au_lname)  AS nVarchar(100)) AS AuthorName, state AS AuthorState
FROM  authors
