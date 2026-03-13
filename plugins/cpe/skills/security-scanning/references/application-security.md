# Application Security

## Injection

### SQL Injection

```javascript
// VULNERABLE — string concatenation
const query = `SELECT * FROM users WHERE email = '${userInput}'`;

// SAFE — parameterized query
const query = 'SELECT * FROM users WHERE email = $1';
db.query(query, [userInput]);
```

Look for: string concatenation in queries, `.format()` in Python DB calls, raw string queries in ORMs.

### Command Injection

```javascript
// VULNERABLE
exec(`ls ${userInput}`);
subprocess.call(f"convert {filename}", shell=True)  # Python

// SAFE
execFile('ls', [userInput]);
subprocess.call(['convert', filename])  # Python — no shell
```

Look for: `exec()`, `eval()`, `system()`, `shell=True`, backtick operators with user input.

### Template Injection

```python
# VULNERABLE — user-controlled template string
template.render(user_provided_template)

# SAFE — template with fixed structure, user data as variables
template.render("Hello {{ name }}", name=user_input)
```

## Authentication & Authorization

### IDOR (Insecure Direct Object Reference)

```javascript
// VULNERABLE — no ownership check
app.get('/documents/:id', async (req, res) => {
  const doc = await db.findById(req.params.id);  // Any user can access any doc
  res.json(doc);
});

// SAFE — verify ownership
app.get('/documents/:id', async (req, res) => {
  const doc = await db.findById(req.params.id);
  if (doc.userId !== req.user.id) return res.status(403).json({ error: 'Forbidden' });
  res.json(doc);
});
```

### JWT Vulnerabilities

```javascript
// VULNERABLE — algorithm confusion attack
jwt.verify(token, secret);  // Accepts 'none' algorithm

// SAFE — explicit algorithm
jwt.verify(token, secret, { algorithms: ['HS256'] });
```

Always verify: `exp` (expiry), `iss` (issuer), `aud` (audience), algorithm explicitly set.

## XSS (Cross-Site Scripting)

```html
<!-- VULNERABLE — direct interpolation -->
<div>${userContent}</div>

<!-- SAFE — framework escaping (React, Vue auto-escape) -->
<div>{userContent}</div>

<!-- DANGEROUS — explicitly bypasses escaping -->
<div dangerouslySetInnerHTML={{ __html: userContent }} />
```

Look for: `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, jQuery `.html()` with user data.

## Path Traversal

```javascript
// VULNERABLE
const file = path.join('./uploads', userInput);  // '../../../etc/passwd'

// SAFE
const file = path.resolve('./uploads', userInput);
if (!file.startsWith(path.resolve('./uploads'))) throw new Error('Invalid path');
```
