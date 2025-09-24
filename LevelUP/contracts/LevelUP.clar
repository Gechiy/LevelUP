;; SkillForge: Professional Skill Development Tracker
;; A decentralized platform for tracking professional growth and expertise

;;Error codes
(define-constant skill-master tx-sender)
(define-constant err-master-only (err u100))
(define-constant err-developer-missing (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-developer-exists (err u103))
(define-constant err-profile-missing (err u104))
(define-constant err-invalid-skill (err u105))
(define-constant err-invalid-data (err u106))

;; Available skill development activities
(define-data-var skill-activities (list 3 (string-ascii 24)) (list "learning" "mentoring" "certification"))

;; Developer tracking maps
(define-map developer-progress 
    principal 
    {
        expertise-level: uint,
        courses-taken: uint,
        mentoring-sessions: uint,
        last-update: uint,
        certifications: uint
    }
)
(define-map activity-values
    {activity: (string-ascii 24)}
    {experience: uint}
)

;; Initialize experience values
(map-set activity-values {activity: "learning"} {experience: u10})
(map-set activity-values {activity: "mentoring"} {experience: u5})
(map-set activity-values {activity: "certification"} {experience: u15})

;; Helper functions
(define-private (is-valid-activity (activity-type (string-ascii 24)))
    (is-some (index-of (var-get skill-activities) activity-type))
)

;; Public functions
(define-public (register-developer)
    (begin
        (asserts! (is-none (get-developer-progress tx-sender)) err-developer-exists)
        (ok (map-set developer-progress tx-sender {
            expertise-level: u0,
            courses-taken: u0,
            mentoring-sessions: u0,
            last-update: stacks-block-height,
            certifications: u0
        }))
    )
)

(define-public (complete-learning)
    (let (
        (profile (unwrap! (get-developer-progress tx-sender) err-profile-missing))
        (exp (get experience (unwrap! (map-get? activity-values {activity: "learning"}) err-invalid-skill)))
    )
    (ok (map-set developer-progress tx-sender (merge profile {
        expertise-level: (+ (get expertise-level profile) exp),
        courses-taken: (+ (get courses-taken profile) u1),
        last-update: stacks-block-height
    })))
    )
)

(define-public (conduct-mentoring)
    (let (
        (profile (unwrap! (get-developer-progress tx-sender) err-profile-missing))
        (exp (get experience (unwrap! (map-get? activity-values {activity: "mentoring"}) err-invalid-skill)))
    )
    (ok (map-set developer-progress tx-sender (merge profile {
        expertise-level: (+ (get expertise-level profile) exp),
        mentoring-sessions: (+ (get mentoring-sessions profile) u1),
        last-update: stacks-block-height
    })))
    )
)

(define-public (earn-certification)
    (let (
        (profile (unwrap! (get-developer-progress tx-sender) err-profile-missing))
        (exp (get experience (unwrap! (map-get? activity-values {activity: "certification"}) err-invalid-skill)))
    )
    (ok (map-set developer-progress tx-sender (merge profile {
        expertise-level: (+ (get expertise-level profile) exp),
        certifications: (+ (get certifications profile) u1),
        last-update: stacks-block-height
    })))
    )
)

;; Admin functions
(define-public (adjust-activity-value (activity-type (string-ascii 24)) (new-exp uint))
    (let
        (
            (max-exp u1000)
            (validated-exp (if (> new-exp max-exp) max-exp new-exp))
        )
        (begin
            (asserts! (is-eq tx-sender skill-master) err-master-only)
            (asserts! (is-valid-activity activity-type) err-invalid-skill)
            (ok (map-set activity-values {activity: activity-type} {experience: validated-exp}))
        )
    )
)

;; Read-only functions
(define-read-only (get-developer-progress (developer principal))
    (map-get? developer-progress developer)
)

(define-read-only (get-activity-experience (activity-type (string-ascii 24)))
    (map-get? activity-values {activity: activity-type})
)

;; Private helper
(define-private (compute-fade (base uint) (duration uint))
    (let (
        (fade-rate (/ duration u1000))
    )
    (if (> fade-rate u0)
        (/ base fade-rate)
        base
    ))
)

;; Active expertise calculation
(define-read-only (get-active-expertise (developer principal))
    (let (
        (profile (unwrap! (get-developer-progress developer) err-developer-missing))
        (idle-time (- stacks-block-height (get last-update profile)))
    )
    (ok (compute-fade (get expertise-level profile) idle-time))
    )
)