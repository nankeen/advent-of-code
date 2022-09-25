# Day 16: Packet Decoder
(I've reformatted the rant and I've written a new entry on December 27.)

Oh gosh, this one was somehow both great and terrible. Terrible because of how long I took to understand it, but pretty fun once I got to implement it. However, in this case, the entertainment I got out of implementing the solution was far overshadowed by the pain I got from simply trying to understand the problem. I have no idea how such a problem could exist, but I guess it does now.

### December 16
Here was my rant that I wrote on December 16.

---

<details>
  <summary>Rant</summary>
  I started to read the problem at 12 AM, got as far as the literal value explanation, and mentally ran away after 5 minutes.
  <br><br>
  So I spent 5 minutes reading the question at midnight, and couldn't understand it. That's understandable.
  <br><br>
  Now, I feel like I either have a very good attention span or a very terrible attention span. I also know that I definitely have a good dose of impatience, so most of the time I default to the terrible attention span.
  <br><br>
  Then during APCS, since I already did the classwork for homework (I didn't properly read the directions saying it wasn't homework), I spent another 20 minutes trying to understand the problem. My heart wasn't really in it, though, and I was pretty frivolous about the whole thing.
  <br><br>
  So I spent 20 minutes reading the question while joking around, and couldn't understand it. That's understandable.
  <br><br>
  I came home, and I finished my homework pretty quickly (I finished most of it on the way home). Then at 7 PM, I came back to this problem. Even though I'd already tried twice before and couldn't understand it, I still wanted to give my best shot at this problem.
  <br><br>
  I took notes like a good student. They were colored and everything so that I could visualize everything better, and I drew a partial flowchart for the packet structure algorithm while taking said notes.<sup><a href="#fn1" id="ref1">1</a></sup> After I finished taking notes and thinking I understood the problem, it was 8 PM.
  <br><br>
  Due to my notes, I had a very good idea of what I wanted my general algorithm to be: recursion through the binary string until the code reached a literal packet.
  <br><br>
  I coded the solution, and it actually was quite fun for a while. I easily implemented the case for a literal packet, but then came time to implement the cases for operator packets...
  <br><br>
  That's when I realized I still didn't fully understand the problem.
  <br><br>
  I reread the problem, and made sure I didn't miss anything from my notes. At around 9:30 PM, I caved and searched Reddit for other people's answers (which I did <b><i>not</i></b> want to do) just so I could understand what the question was asking for. I wanted to understand this problem, but I couldn't for some reason. I still can't find a good explanation for where 11 and 16 come from for the sample input for <code>38006F45291200</code>, and where the three 11s come from for the sample input for <code>EE00D40C823060</code>. Am I supposed to find these numbers myself, iterate through all the cases? From what I saw of other people's solutions, it doesn't look like that's what I'm supposed to do. But if I were to run the rest of the packet (after the length type ID) recursively, that wouldn't give me two packets, that would give me one.
  <br><br>
  I stopped trying at 11 PM. I started feeling very uncomfortable (yes, me being upset makes me uncomfortable) at around 10:30 PM, and still trucked on. I couldn't understand what I had missed that everyone else had seen, even after having checked the problem description and other people's logic so many times. There have been jokes of my reading comprehension being subpar since I often don't read any instructions carefully, but a part of me wonders if that those jokes tell the truth. After all, this time, I really had read the problem carefully, very carefully.
  <br><br>
  I need a break from AoC.
  <br><br>
  <sup id="fn1">1. Well, it <i>kind of</i> looked like a flowchart to me.<a href="#ref1">↩</a></sup>
</details>

---

And here were my notes on the problem (further described in the rant):

![image](notes.jpg)

### December 27
Since I'm terrible at reading and understanding directions, I enlisted the help of my APCS teacher on December 17. (Sorry for interrupting your lunch break!) Seems like I did miss something after all--literal values end after a group with a "`0`". That wasn't explicitly mentioned in my notes.

I also didn't feel like doing AoC on December 17 because I was still mentally recovering from those 4 hours, and I just didn't feel like doing Problem 16 afterwards. So I guess I got bored today and chose to finally complete 16 since, hey, I understood everything after all. Also, I read the other AoC problems and noped out. (I've done [Problem 22](https://github.com/Daphne-Qin/AdventOfCode2021/tree/main/Problem22) on three separate days as of right now, and I'm still not anywhere close to solving it. I hate PIE.)

I decided to scrap my [original partial solution](https://github.com/Daphne-Qin/AdventOfCode2021/blob/dbc6ea11867851aef2ac7e5b182ced83ea222e7e/Problem16/Problem16.java), which involved me taking the substring of the original binary string multiple times. Instead, I decided to increment by the index as it was clear that I'd have to do this recursively and the end of one subpacket meant the beginning of the next.

I quite easily implemented both the literals and the operators this time. For the literals, I already had the numbers from my previous solution, and just needed to add `i` to some of the substrings and increment `i`. Then the operators weren't too hard either since I only really had to implement the recursive part.

Once I finished Part 1 (took 11 days in total), I was able to code Part 2 without much incident. As indicated in my notes, I already knew that there were going to be operations, so instead of returning the version number I had the literal return its actual value, had the operators return 0 as a placeholder, and had the `versionNumberSum` be a static field. Thus, all I had to do for Part 2 was code the operations to replace the `return 0`.

Something very annoying that happened, though, was that I kept getting `1675198554896` as my answer to Part 2. I couldn't figure out what I did wrong, and I thought `long`s worked exactly like `int`s. Upon further inspection, though, I realized I capitalized the `L` in `Long`, so I simply made it lowercase. (If I had kept it capitalized, I would've had to use `.equals()` instead of `==`, [for some caching reason that I don't fully understand](https://stackoverflow.com/questions/19485818/why-are-2-long-variables-not-equal-with-operator-in-java).) I got the correct answer shortly afterwards.

### Final Verdict
I'm able to forgive this problem a little bit for how much fun it was to write out the actual solution. For some reason, I liked the whole index-incrementing nature of this problem. In my opinion, the difficulty of implementing the solution itself is relatively easy for a Problem 16 (or any problem that's towards the middle of the calendar). But what I'm not able to forgive it for is the 4 hours of me trying to understand the question. The length and difficulty of the problem description is more than enough to warrant its position. I'm not about to repeat the rant because I'd probably go on for forever about it, but long story short, it was *horrible*. This still remains at the top of my [list of annoying problems](https://github.com/Daphne-Qin/AdventOfCode2021#most-annoying-problems), and honestly, I don't see it ever leaving the number one spot.

### Answers
| Part 1 | Part 2 |
| :---: | :---: |
| 883 | 1675198555015 |

## Part 1
As you leave the cave and reach open waters, you receive a transmission from the Elves back on the ship.

The transmission was sent using the Buoyancy Interchange Transmission System (BITS), a method of packing numeric expressions into a binary sequence. Your submarine's computer has saved the transmission in [hexadecimal](https://en.wikipedia.org/wiki/Hexadecimal) (your puzzle input).

The first step of decoding the message is to convert the hexadecimal representation into binary. Each character of hexadecimal corresponds to four bits of binary data:

```
0 = 0000
1 = 0001
2 = 0010
3 = 0011
4 = 0100
5 = 0101
6 = 0110
7 = 0111
8 = 1000
9 = 1001
A = 1010
B = 1011
C = 1100
D = 1101
E = 1110
F = 1111
```

The BITS transmission contains a single **packet** at its outermost layer which itself contains many other packets. The hexadecimal representation of this packet might encode a few extra `0` bits at the end; these are not part of the transmission and should be ignored.

Every packet begins with a standard header: the first three bits encode the packet **version**, and the next three bits encode the packet **type ID**. These two values are numbers; all numbers encoded in any packet are represented as binary with the most significant bit first. For example, a version encoded as the binary sequence `100` represents the number `4`.

Packets with type ID `4` represent a **literal value**. Literal value packets encode a single binary number. To do this, the binary number is padded with leading zeroes until its length is a multiple of four bits, and then it is broken into groups of four bits. Each group is prefixed by a `1` bit except the last group, which is prefixed by a `0` bit. These groups of five bits immediately follow the packet header. For example, the hexadecimal string `D2FE28` becomes:

```
110100101111111000101000
VVVTTTAAAAABBBBBCCCCC
```

Below each bit is a label indicating its purpose:

- The three bits labeled `V` (`110`) are the packet version, `6`.
- The three bits labeled `T` (`100`) are the packet type ID, `4`, which means the packet is a literal value.
- The five bits labeled `A` (10111) start with a `1` (not the last group, keep reading) and contain the first four bits of the number, `0111`.
- The five bits labeled `B` (11110) start with a `1` (not the last group, keep reading) and contain four more bits of the number, `1110`.
T- he five bits labeled `C` (00101) start with a `0` (last group, end of packet) and contain the last four bits of the number, `0101`.
- The three unlabeled `0` bits at the end are extra due to the hexadecimal representation and should be ignored.

So, this packet represents a literal value with binary representation `011111100101`, which is `2021` in decimal.

Every other type of packet (any packet with a type ID other than `4`) represent an **operator** that performs some calculation on one or more sub-packets contained within. Right now, the specific operations aren't important; focus on parsing the hierarchy of sub-packets.

An operator packet contains one or more packets. To indicate which subsequent binary data represents its sub-packets, an operator packet can use one of two modes indicated by the bit immediately after the packet header; this is called the **length type ID**:

- If the length type ID is `0`, then the next **15** bits are a number that represents the total length in bits of the sub-packets contained by this packet.
- If the length type ID is `1`, then the next **11** bits are a number that represents the number of sub-packets immediately contained by this packet.

Finally, after the length type ID bit and the 15-bit or 11-bit field, the sub-packets appear.

For example, here is an operator packet (hexadecimal string `38006F45291200`) with length type ID `0` that contains two sub-packets:

```
00111000000000000110111101000101001010010001001000000000
VVVTTTILLLLLLLLLLLLLLLAAAAAAAAAAABBBBBBBBBBBBBBBB
```

- The three bits labeled `V` (`001`) are the packet version, `1`.
- The three bits labeled `T` (`110`) are the packet type ID, `6`, which means the packet is an operator.
- The bit labeled `I` (`0`) is the length type ID, which indicates that the length is a 15-bit number representing the number of bits in the sub-packets.
- The 15 bits labeled `L` (`000000000011011`) contain the length of the sub-packets in bits, `27`.
- The 11 bits labeled `A` contain the first sub-packet, a literal value representing the number `10`.
- The 16 bits labeled `B` contain the second sub-packet, a literal value representing the number `20`.

After reading 11 and 16 bits of sub-packet data, the total length indicated in `L` (27) is reached, and so parsing of this packet stops.

As another example, here is an operator packet (hexadecimal string `EE00D40C823060`) with length type ID `1` that contains three sub-packets:

```
11101110000000001101010000001100100000100011000001100000
VVVTTTILLLLLLLLLLLAAAAAAAAAAABBBBBBBBBBBCCCCCCCCCCC
```

- The three bits labeled `V` (`111`) are the packet version, `7`.
- The three bits labeled `T` (`011`) are the packet type ID, `3`, which means the packet is an operator.
- The bit labeled `I` (`1`) is the length type ID, which indicates that the length is a 11-bit number representing the number of sub-packets.
- The 11 bits labeled `L` (`00000000011`) contain the number of sub-packets, `3`.
- The 11 bits labeled `A` contain the first sub-packet, a literal value representing the number `1`.
- The 11 bits labeled `B` contain the second sub-packet, a literal value representing the number `2`.
- The 11 bits labeled `C` contain the third sub-packet, a literal value representing the number `3`.

After reading 3 complete sub-packets, the number of sub-packets indicated in `L` (3) is reached, and so parsing of this packet stops.

For now, parse the hierarchy of the packets throughout the transmission and **add up all of the version numbers**.

Here are a few more examples of hexadecimal-encoded transmissions:

- `8A004A801A8002F478` represents an operator packet (version 4) which contains an operator packet (version 1) which contains an operator packet (version 5) which contains a literal value (version 6); this packet has a version sum of **16**.
- `620080001611562C8802118E34` represents an operator packet (version 3) which contains two sub-packets; each sub-packet is an operator packet that contains two literal values. This packet has a version sum of **12**.
- `C0015000016115A2E0802F182340` has the same structure as the previous example, but the outermost packet uses a different length type ID. This packet has a version sum of **23**.
- `A0016C880162017C3686B18A3D4780` is an operator packet that contains an operator packet that contains an operator packet that contains five literal values; it has a version sum of **31**.

Decode the structure of your hexadecimal-encoded BITS transmission; **what do you get if you add up the version numbers in all packets?**

## Part 2
Now that you have the structure of your transmission decoded, you can calculate the value of the expression it represents.

Literal values (type ID `4`) represent a single number as described above. The remaining type IDs are more interesting:

- Packets with type ID `0` are **sum** packets - their value is the sum of the values of their sub-packets. If they only have a single sub-packet, their value is the value of the sub-packet.
- Packets with type ID `1` are **product** packets - their value is the result of multiplying together the values of their sub-packets. If they only have a single sub-packet, their value is the value of the sub-packet.
- Packets with type ID `2` are **minimum** packets - their value is the minimum of the values of their sub-packets.
- Packets with type ID `3` are **maximum** packets - their value is the maximum of the values of their sub-packets.
- Packets with type ID `5` are **greater than** packets - their value is **1** if the value of the first sub-packet is greater than the value of the second sub-packet; otherwise, their value is **0**. These packets always have exactly two sub-packets.
- Packets with type ID `6` are **less than** packets - their value is **1** if the value of the first sub-packet is less than the value of the second sub-packet; otherwise, their value is **0**. These packets always have exactly two sub-packets.
- Packets with type ID `7` are **equal to** packets - their value is **1** if the value of the first sub-packet is equal to the value of the second sub-packet; otherwise, their value is **0**. These packets always have exactly two sub-packets.

Using these rules, you can now work out the value of the outermost packet in your BITS transmission.

For example:

- `C200B40A82` finds the sum of `1` and `2`, resulting in the value **3**.
- `04005AC33890` finds the product of `6` and `9`, resulting in the value **54**.
- `880086C3E88112` finds the minimum of `7`, `8`, and `9`, resulting in the value **7**.
- `CE00C43D881120` finds the maximum of `7`, `8`, and `9`, resulting in the value **9**.
- `D8005AC2A8F0` produces `1`, because `5` is less than `15`.
- `F600BC2D8F` produces `0`, because `5` is not greater than `15`.
- `9C005AC2F8F0` produces `0`, because `5` is not equal to `15`.
- `9C0141080250320F1802104A08` produces `1`, because `1` + `3` = `2` * `2`.

**What do you get if you evaluate the expression represented by your hexadecimal-encoded BITS transmission?**
