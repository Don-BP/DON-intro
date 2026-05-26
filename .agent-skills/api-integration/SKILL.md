---
name: api-integration
description: API integration combining REST, GraphQL, MCP servers, authentication patterns, rate limiting, and multi-API coordination
---

# API Integration - Enhanced Edition

Complete API integration framework combining **REST/GraphQL** patterns, **MCP server creation**, **multi-API coordination**, **authentication** (OAuth, JWT, API keys), **rate limiting/caching**, and **security best practices**.

## When to Use

- ✅ Integrating **external APIs** (REST, GraphQL, webhooks)
- ✅ Building **MCP servers** for custom tool integration
- ✅ Implementing **OAuth/JWT** authentication
- ✅ **Rate limiting** and **caching** strategies
- ✅ **Error handling** and **retry logic**
- ✅ **Multi-API** coordination in single workflow
- ✅ API **monitoring** and **health checks**

## Core Patterns

### 1. REST API Integration

```javascript
class APIClient {
  constructor(baseURL, apiKey) {
    this.baseURL = baseURL;
    this.apiKey = apiKey;
    this.cache = new Map();
  }

  async request(method, endpoint, body = null, options = {}) {
    const url = `${this.baseURL}/${endpoint}`;
    const cacheKey = `${method}:${url}`;

    // Check cache
    if (method === 'GET' && this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }

    const config = {
      method,
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
        ...options.headers
      }
    };

    if (body) config.body = JSON.stringify(body);

    // Retry logic
    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        const response = await fetch(url, config);

        if (!response.ok) {
          if (response.status === 429) { // Rate limited
            const retryAfter = parseInt(response.headers.get('Retry-After') || '60');
            await new Promise(resolve => setTimeout(resolve, retryAfter * 1000));
            continue;
          }
          throw new Error(`API Error: ${response.statusText}`);
        }

        const data = await response.json();

        // Cache successful GET responses (5 min TTL)
        if (method === 'GET') {
          this.cache.set(cacheKey, data);
          setTimeout(() => this.cache.delete(cacheKey), 5 * 60 * 1000);
        }

        return data;
      } catch (error) {
        if (attempt === 3) throw error;
        await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
      }
    }
  }

  get(endpoint) { return this.request('GET', endpoint); }
  post(endpoint, body) { return this.request('POST', endpoint, body); }
  put(endpoint, body) { return this.request('PUT', endpoint, body); }
  delete(endpoint) { return this.request('DELETE', endpoint); }
}
```

### 2. GraphQL Integration

```javascript
const apolloClient = new ApolloClient({
  uri: 'https://api.example.com/graphql',
  cache: new InMemoryCache(),
  link: ApolloLink.from([
    new HttpLink({
      uri: 'https://api.example.com/graphql',
      credentials: 'include',
      headers: {
        authorization: `Bearer ${token}`
      }
    })
  ])
});

const query = gql`
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
      posts {
        id
        title
      }
    }
  }
`;

const result = await apolloClient.query({
  query,
  variables: { id: '123' }
});
```

### 3. OAuth 2.0 Flow

```javascript
// Authorization Code Flow
async function getAccessToken(code) {
  const response = await fetch('https://provider.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      grant_type: 'authorization_code',
      code,
      client_id: process.env.CLIENT_ID,
      client_secret: process.env.CLIENT_SECRET,
      redirect_uri: 'http://localhost:3000/callback'
    })
  });

  const { access_token, refresh_token, expires_in } = await response.json();

  // Store securely in httpOnly cookie or secure storage
  storeAccessToken(access_token);
  storeRefreshToken(refresh_token);

  return { access_token, expires_in };
}

// Auto-refresh before expiration
async function refreshAccessToken() {
  const refreshToken = getStoredRefreshToken();

  const response = await fetch('https://provider.com/token', {
    method: 'POST',
    body: new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token,
      client_id: process.env.CLIENT_ID,
      client_secret: process.env.CLIENT_SECRET
    })
  });

  const { access_token } = await response.json();
  storeAccessToken(access_token);

  return access_token;
}
```

### 4. MCP Server Creation

```javascript
// Simple MCP Server
import { Server } from '@anthropic-ai/sdk/index.js';
import { Tool } from '@anthropic-ai/sdk/resources/messages.js';

const server = new Server({
  name: 'my-tools',
  version: '1.0.0'
});

// Define a tool
const fetchUserTool = {
  name: 'fetch_user',
  description: 'Fetch user data from API',
  inputSchema: {
    type: 'object',
    properties: {
      userId: {
        type: 'string',
        description: 'User ID to fetch'
      }
    },
    required: ['userId']
  }
};

// Register tool handler
server.tool('fetch_user', async (input) => {
  const { userId } = input;
  const response = await fetch(`/api/users/${userId}`);
  return await response.json();
});

// Start server
server.start();
```

### 5. Multi-API Coordination

```javascript
class APIOrchestrator {
  constructor(apis) {
    this.apis = apis; // Map of API clients
  }

  async fetchAndProcess() {
    try {
      // Parallel API calls
      const [users, posts, comments] = await Promise.all([
        this.apis.userService.get('users'),
        this.apis.postService.get('posts'),
        this.apis.commentService.get('comments')
      ]);

      // Transform data
      const enriched = users.map(user => ({
        ...user,
        posts: posts.filter(p => p.userId === user.id),
        commentCount: comments.filter(c =>
          posts.some(p => p.id === c.postId && p.userId === user.id)
        ).length
      }));

      return enriched;
    } catch (error) {
      console.error('Orchestration failed:', error);
      throw error;
    }
  }
}
```

### 6. Rate Limiting & Backoff

```javascript
class RateLimiter {
  constructor(maxRequests = 100, windowMs = 60000) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.requests = [];
  }

  async wait() {
    const now = Date.now();
    this.requests = this.requests.filter(time => now - time < this.windowMs);

    if (this.requests.length >= this.maxRequests) {
      const oldestRequest = this.requests[0];
      const waitTime = this.windowMs - (now - oldestRequest);
      await new Promise(resolve => setTimeout(resolve, waitTime));
      return this.wait();
    }

    this.requests.push(now);
  }
}

// Exponential backoff
async function exponentialBackoff(fn, maxAttempts = 5) {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxAttempts) throw error;

      const delay = Math.pow(2, attempt - 1) * 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

## Security Best Practices

- ✅ Store API keys in environment variables (never commit to repo)
- ✅ Use **least-privilege** scopes in OAuth
- ✅ **Validate** all API responses
- ✅ **Log** API calls (but not secrets)
- ✅ **Rotate** tokens and secrets regularly
- ✅ Use **HTTPS** only
- ✅ Implement **request signing** for sensitive APIs
- ✅ Set appropriate **CORS** headers

## Common Use Cases

1. **Data Aggregation** → Combine data from multiple APIs
2. **Webhook Handlers** → Respond to external events
3. **Sync Services** → Keep data in sync across systems
4. **Custom Integrations** → Build internal tool integrations
5. **API Proxies** → Add authentication layer to public APIs

---

**Enhanced version combining REST, GraphQL, MCP, OAuth, multi-API coordination, rate limiting, and security.**
