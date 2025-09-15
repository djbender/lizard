# Security Improvement Plan

This document outlines security enhancements needed before deploying Lizard to production.

## Phase 1: Critical Security (Must Have)

### 1.1 User Authentication & Authorization
- **Task**: Implement user authentication system
- **Priority**: Critical
- **Implementation**:
  - Add Devise gem for user authentication
  - Create User model with email/password
  - Associate projects with users (`belongs_to :user`)
  - Add authentication filters to all controllers
  - Implement authorization (users can only access their projects)
- **Testing**: User registration, login, project isolation
- **Effort**: 2-3 days

### 1.2 API Key Security
- **Task**: Implement secure API key management
- **Priority**: Critical
- **Implementation**:
  - Hash API keys using BCrypt (store digest, not plaintext)
  - Add `api_key_digest` column to projects table
  - Implement secure key generation and comparison
  - Add key regeneration functionality
  - Remove API keys from all logs and error messages
- **Testing**: API authentication still works, keys not visible
- **Effort**: 1-2 days

### 1.3 HTTPS & SSL
- **Task**: Force HTTPS in production
- **Priority**: Critical
- **Implementation**:
  - Set `config.force_ssl = true` in production
  - Configure SSL certificates (Let's Encrypt or cloud provider)
  - Update HSTS headers
  - Ensure all external resources use HTTPS
- **Testing**: HTTP redirects to HTTPS, no mixed content warnings
- **Effort**: 1 day

### 1.4 Rate Limiting
- **Task**: Protect against API abuse
- **Priority**: High
- **Implementation**:
  - Add rack-attack gem
  - Implement rate limiting per API key (e.g., 1000 requests/hour)
  - Add IP-based rate limiting for web interface
  - Configure throttling for failed authentication attempts
- **Testing**: Rate limits enforce correctly, legitimate traffic unaffected
- **Effort**: 1 day

## Phase 2: Important Security (Should Have)

### 2.1 Input Validation & Sanitization
- **Task**: Prevent XSS and validate all inputs
- **Priority**: High
- **Implementation**:
  - Sanitize project names and all user inputs for HTML display
  - Add stronger validation for test run parameters
  - Validate branch names, commit SHAs format
  - Add length limits on all string fields
  - Sanitize error messages shown to users
- **Testing**: XSS attempts blocked, malformed input rejected
- **Effort**: 1-2 days

### 2.2 API Key Scoping & Expiration
- **Task**: Improve API key management
- **Priority**: Medium
- **Implementation**:
  - Add expiration dates to API keys
  - Implement key scoping (read-only vs read-write)
  - Add last_used_at tracking
  - Implement automatic key rotation warnings
  - Add ability to have multiple keys per project
- **Testing**: Expired keys rejected, scoped access works
- **Effort**: 2 days

### 2.3 Data Retention & Privacy
- **Task**: Implement data management policies
- **Priority**: Medium
- **Implementation**:
  - Add configurable data retention (auto-delete old test runs)
  - Implement data export functionality for users
  - Add privacy settings for projects (private/public)
  - Consider anonymizing or hashing sensitive data (commit SHAs)
- **Testing**: Old data purged correctly, exports work
- **Effort**: 2-3 days

### 2.4 Security Headers & CORS
- **Task**: Implement proper HTTP security headers
- **Priority**: Medium
- **Implementation**:
  - Add security headers (CSP, X-Frame-Options, etc.)
  - Configure CORS properly if needed for browser clients
  - Add rack-cors gem if cross-origin requests required
  - Set secure cookie flags
- **Testing**: Security scanners pass, legitimate requests work
- **Effort**: 1 day

## Phase 3: Nice to Have Security

### 3.1 Advanced Monitoring
- **Task**: Security monitoring and alerting
- **Priority**: Low
- **Implementation**:
  - Log security events (failed logins, rate limit hits)
  - Add anomaly detection for unusual API usage
  - Implement security metrics dashboard
  - Set up alerts for suspicious activity
- **Testing**: Security events logged and alerting works
- **Effort**: 2-3 days

### 3.2 Database Security
- **Task**: Enhance database security
- **Priority**: Low
- **Implementation**:
  - Implement database encryption at rest
  - Add query auditing for sensitive operations
  - Use read-only database connections where possible
  - Implement backup encryption
- **Testing**: Data encrypted, audit logs working
- **Effort**: 2-3 days

### 3.3 Infrastructure Security
- **Task**: Secure deployment infrastructure
- **Priority**: Low
- **Implementation**:
  - Container security scanning in CI/CD
  - Network segmentation and firewall rules
  - Secret management system (HashiCorp Vault, AWS Secrets Manager)
  - Regular security dependency updates
- **Testing**: Security scans pass, secrets properly managed
- **Effort**: 3-4 days

## Implementation Order

1. **Week 1**: User authentication, API key hashing, HTTPS
2. **Week 2**: Rate limiting, input validation, basic security headers
3. **Week 3**: API key expiration, data retention policies
4. **Week 4**: Advanced monitoring, final security review

## Security Testing Checklist

- [ ] No API keys visible in logs or error messages
- [ ] Users can only access their own projects
- [ ] Rate limiting prevents abuse
- [ ] XSS attempts are blocked
- [ ] HTTPS is enforced everywhere
- [ ] Failed authentication is logged
- [ ] Old data is automatically cleaned up
- [ ] Security headers are present
- [ ] Dependencies are up to date
- [ ] Penetration testing completed

## Risk Assessment

| Risk | Current Level | After Phase 1 | After Phase 2 | After Phase 3 |
|------|---------------|----------------|----------------|----------------|
| Data Breach | High | Medium | Low | Very Low |
| API Abuse | High | Low | Very Low | Very Low |
| XSS Attacks | Medium | Medium | Very Low | Very Low |
| Unauthorized Access | High | Low | Very Low | Very Low |
| Data Loss | Medium | Medium | Low | Very Low |

## Dependencies

- **Authentication**: Devise gem
- **API Key Hashing**: BCrypt (already included)
- **Rate Limiting**: rack-attack gem
- **Security Headers**: rack-cors gem (if needed)
- **Monitoring**: Consider Rollbar, Sentry, or DataDog

## Maintenance

- Monthly security dependency updates
- Quarterly security review
- Annual penetration testing
- Regular backup testing
- Monitor security bulletins for Rails and dependencies