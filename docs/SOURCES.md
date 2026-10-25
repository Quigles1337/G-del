# Sources

Citations for the history, the law, and the logic. Where this repository
is repeating a well-attested fact it says so plainly; where it is
repeating a *story*, or taking a side in a live doctrinal dispute, it
says that too. Confidence markers are deliberate — a formalization that
launders uncertainty in its prose has cheated at exactly the point it
claims rigour.

## 1. The hearing

Gödel's naturalization hearing took place on **5 December 1947** — the
date is Dawson's — in Trenton, New Jersey, before Judge Phillip Forman
(named by Lipton and Regan, below, who spell it "Philip"; the spelling
here is the Federal Judicial Center's,
<https://www.fjc.gov/history/judges/forman-phillip>). Albert Einstein and
Oskar Morgenstern accompanied him as witnesses. In preparing, Gödel
became convinced he had found a way in which the United States could
legally become a dictatorship, and he began to raise it at the hearing;
Forman steered the conversation away and the citizenship was granted.

- **Oskar Morgenstern**, memorandum "History of the Naturalization of
  Kurt Gödel", dated **13 September 1971**. The Institute for Advanced
  Study's copy, given by Morgenstern's widow in 2005, is catalogued as
  "Oskar Morgenstern's account of Kurt Gödel's naturalization", Dorothy
  Morgenstern Thomas collection related to Kurt Gödel, Shelby White and
  Leon Levy Archives Center, Institute for Advanced Study, Princeton, NJ:
  <https://hdl.handle.net/20.500.12111/2333>. This is the primary source
  for the drive to Trenton and the exchange in the courtroom. Its
  opening lines say it was dictated from memory, without notes, and it
  gives a year but not the day: "It was in 1946 that Gödel was to
  become an American citizen." A transcription is at
  <https://mathshistory.st-andrews.ac.uk/Extras/Godel_naturalisation/>;
  it prints that year as 1947.
- **John W. Dawson, Jr.**, *Logical Dilemmas: The Life and Work of Kurt
  Gödel* (A K Peters, 1997). The standard biography; covers the hearing,
  and is the source of the date 5 December 1947.
- **Jeffrey Kegler**, "Kurt Gödel: A Contradiction in the U.S.
  Constitution?", <https://jeffreykegler.github.io/personal/morgenstern.html>
  — the hearing's legend, and how the memorandum, long thought lost,
  turned up at the Institute. Mark Dominus was already reporting Kegler's
  find on 21 January 2009, in "The loophole in the U.S. Constitution:
  recent developments",
  <https://blog.plover.com/law/Godel-dictatorship-3.html>.
- **Richard J. Lipton and Kenneth W. Regan**, "Judging A Book By Its
  Coverage", *Gödel's Lost Letter and P=NP*, 6 December 2013,
  <https://rjlipton.com/2013/12/06/judging-a-book-by-its-coverage/> —
  quotes the memorandum, notes that the only year it gives is 1946, and
  names the judge.

*Dates:* the memorandum's only year, in the Institute's scan of it, is
1946. The Institute's catalogue record ("1946 interview") and Lipton
and Regan match it; the St Andrews transcription and the Institute's
finding aid give 1947 instead. The date 5 December 1947 is Dawson's,
and Morgenstern's opening lines themselves leave the memorandum's dates
to be checked later.

**What is NOT attested:** the argument itself. No written version by
Gödel is known, and Morgenstern did not record its content. Everything past "there was an
argument" is reconstruction, including everything in this repository.

## 2. The reconstruction premise

- **Peter Suber**, *The Paradox of Self-Amendment: A Study of Logic, Law,
  Omnipotence, and Change* (Peter Lang, 1990). The source of this
  repository's framing: treat the rule of change as an object-level
  provision and ask what follows. Suber makes the case at book length
  that self-amendment is coherent but not innocent. Freely available from
  the author online.
- **Alf Ross**, "On Self-Reference and a Puzzle in Constitutional Law",
  *Mind* 78 (1969). Argues that a self-amending amendment clause is
  paradoxical. Suber's book is in large part a reply.
- **F. E. Guerra-Pujol**, "Gödel's Loophole," *Capital University Law
  Review* 41 (2013): 637–673. SSRN: <https://ssrn.com/abstract=2010183>.
  The best-known scholarly attempt to reconstruct what Gödel might have
  had in mind. Its candidate turns on Article V.

*Confidence:* Suber and Ross are certain.

## 3. Article V, and why Movement B is not hypothetical

Article V of the U.S. Constitution contains two substantive
entrenchments. One — protecting the slave trade until 1808 — expired by
its own terms. The other is live:

> ...no State, without its Consent, shall be deprived of its equal
> Suffrage in the Senate.

This clause protects equal state suffrage. **It does not, in its text,
protect itself.** On the reading **Movement B** formalizes, Article V is
an ordinary article, amendable by the ordinary Article V process: a
guard that guards the provisions but not the guard. The two-step —
amend Article V to delete the proviso, then amend the Senate — has the
shape of `entrenchment_bypassed`.

Whether this two-step is *lawful* is contested among constitutional
scholars; whether it is *formally derivable* in a system that models
Article V as an object-level provision is not contested, and is the
theorem in this repository. Movement B does not settle the legal question
and does not try to. See [LIMITATIONS.md](LIMITATIONS.md).

## 4. Weimar: the loophole with a body count

- **Weimar Constitution (1919), Article 76** — permitted constitutional
  amendment by a two-thirds majority of the Reichstag, with **no
  substantive limits whatever**. Movement A's regime `VA` is modelled on
  Article 76.
- **Article 48** — emergency decree powers of the Reichspräsident.
- **Ermächtigungsgesetz ("Enabling Act"), 23 March 1933** — passed with
  the two-thirds majority a constitutional amendment needed *under
  Article 76*, transferring legislative power to the cabinet, including
  power to deviate from the constitution. **The vote was coerced.** The
  81 KPD mandates had been annulled under the Reichstag Fire Decree of
  28 February; 26 SPD deputies were in "protective custody" or had fled;
  the standing orders were changed at the start of the sitting so that
  absent deputies could count as present; the SS cordoned the Kroll
  Opera House and armed SA men stood inside. (By the Bundestag's
  account the two-thirds would have been reached even without the
  annulled mandates.) Sources: Deutscher Bundestag, "23. März 1933:
  Reichstag billigt „Ermächtigungsgesetz“",
  <https://www.bundestag.de/dokumente/textarchiv/1933-03-23-ermaechtigungsgesetz-938540>;
  United States Holocaust Memorial Museum, "The Enabling Act of 1933",
  Holocaust Encyclopedia,
  <https://encyclopedia.ushmm.org/content/en/article/the-enabling-act>;
  Anne Frank House, "The Enabling Act: even more power for Hitler",
  <https://www.annefrank.org/en/timeline/48/the-enabling-act-even-more-power-for-hitler/>.

This is the loophole shape as historical analogy rather than as toy: an
amendment that changed not a substantive right but **who may change
things**, and thereby repriced everything downstream. The analogy is to
that transfer of rule-making authority, and only to it. Coercion was
part of the episode; the toy has no actors and no coercion, and models
none of it ([LIMITATIONS.md](LIMITATIONS.md) §2). It is the reason
`loophole_decree` is in the file.

*Confidence:* high on Art. 76, Art. 48, the Enabling Act's date and
mechanism, and the coercion around the vote.

## 5. Grundgesetz Art. 79(3) — and a nuance the toy flattens

The German Basic Law (1949) was written by people who had watched
Article 76's procedure carry the Enabling Act, under intimidation (§4).
Art. 79(3), the *Ewigkeitsklausel*
("eternity clause"), declares inadmissible any amendment affecting the
division of the Federation into Länder, the Länder's participation in
legislation, or **the principles laid down in Articles 1 and 20** (human
dignity; the democratic, federal, social state governed by the rule of
law).

**The nuance:** Art. 79(3) does not, in its text, name itself. Movement C
models a clause that explicitly protects itself (`selfAttack`), which is
*stronger than the German text as written*. The dominant German doctrine
reaches the same place by a different route — repealing 79(3) would
itself "affect" the principles it protects, so the repeal is inadmissible
— and the Federal Constitutional Court has treated the clause as beyond
the amending power. But that is **doctrine supplying self-entrenchment
that the text does not literally state**, which is itself a small
instance of Movement D: the protection depends on how the recognizing
institution reads it.

So: Movement C is faithful to Art. 79(3) *as understood*, not to
Art. 79(3) *as written*. This repository takes the doctrinal reading
because it is the stronger opponent — it is more interesting to defeat a
defence at its best. Flagged here rather than buried.

- **Yaniv Roznai**, *Unconstitutional Constitutional Amendments: The
  Limits of Amendment Powers* (Oxford University Press, 2017). The
  standard modern treatment of eternity clauses and substantive limits on
  amendment, comparative in scope.

## 6. The recognizer, and why it cannot be entrenched

Movement D's claim is jurisprudential before it is formal: the predicate
that decides what counts as valid law is applied by institutions, and
those institutions are not themselves creatures of the text.

- **H. L. A. Hart**, *The Concept of Law* (Oxford, 1961). The **rule of
  recognition** is a *social practice* among officials, not a legal norm
  validated by a higher legal norm. It therefore cannot be entrenched by
  law — there is no law above it to do the entrenching. This is the
  direct jurisprudential warrant for making `strictInterp` a state
  variable that no clause governs.
- **Hans Kelsen**, *Pure Theory of Law* — the *Grundnorm*, reached by the
  same regress from a different direction.
- **Carl Schmitt**, *Verfassungslehre* (1928) — *pouvoir constituant*
  versus *pouvoir constitué*. The distinction is the doctrinal engine of
  "a new constitution is not an amendment to the old," which is the move
  Movement D models. Cited because it is the relevant theory, not because
  the repository endorses its author or its politics.

## 7. Modern recognizer capture

Three often-cited episodes. They are **not** the same shape, and the
comment in the original source file lumped them together too quickly.
Corrected here:

- **Hungary, 2010–2013.** A two-thirds parliamentary majority enacted a
  new Fundamental Law (2011, in force 2012); the Fourth Amendment (2013)
  annulled the Constitutional Court's pre-2012 case law and narrowed its
  power to review amendments for substance. This is the closest fit to
  `setInterp false`: the recognizing institution's capacity to read the
  text as binding was reduced *by valid procedure*.
- **Venezuela, 2017.** A Constituent National Assembly was convened and
  claimed powers superior to the sitting legislature. This is the
  *pouvoir constituant* gambit — not an amendment at all, which is
  exactly why Movement D models capture as ungoverned by the amendment
  rule.
- **Honduras, 2009.** Cuts the **other way**, and is included as a
  counter-example rather than an example. Honduras's constitution
  contains unamendable ("pétreos") articles; the removal of President
  Zelaya was justified by invoking them against him. An eternity clause
  can be the instrument of a seizure as easily as its target. The toy
  cannot represent this at all — it has no actors, so it cannot model a
  clause being *wielded*. See [LIMITATIONS.md](LIMITATIONS.md).

*Confidence:* the broad facts are well attested; the characterisations
are contested in each case, and the legal literature disagrees about all
three. Nothing in the Lean development depends on them.

## 8. The logic

- **Kurt Gödel**, "Über formal unentscheidbare Sätze der Principia
  Mathematica und verwandter Systeme I" (1931). The second incompleteness
  theorem is an analogy the repository draws, and only an analogy:
  `eternity_holds` is a safety theorem about system C, proved in Lean
  with `V` held fixed, and Movement D shows it failing once capture can
  change the recognizer.
  **No formal reduction of Gödel II to the constitutional case is claimed
  or attempted.** See [LIMITATIONS.md](LIMITATIONS.md) §"The rhyme is a
  rhyme".
