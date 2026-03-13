import Foundation

@Observable
@MainActor
class StorageService {
    var projects: [EpoxyProject] = []
    var adminSettings: AdminSettings = .defaultSettings

    private let projectsKey = "epoxy_projects"
    private let adminKey = "epoxy_admin_settings"
    private let pinKey = "epoxy_admin_pin"

    init() {
        loadProjects()
        loadAdminSettings()
    }

    func saveProject(_ project: EpoxyProject) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        } else {
            projects.insert(project, at: 0)
        }
        persistProjects()
    }

    func deleteProject(_ project: EpoxyProject) {
        projects.removeAll { $0.id == project.id }
        persistProjects()
    }

    func saveAdminSettings(_ settings: AdminSettings) {
        adminSettings = settings
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: adminKey)
        }
    }

    func getAdminPIN() -> String {
        UserDefaults.standard.string(forKey: pinKey) ?? "1234"
    }

    func setAdminPIN(_ pin: String) {
        UserDefaults.standard.set(pin, forKey: pinKey)
    }

    private func loadProjects() {
        guard let data = UserDefaults.standard.data(forKey: projectsKey),
              let decoded = try? JSONDecoder().decode([EpoxyProject].self, from: data) else { return }
        projects = decoded
    }

    private func persistProjects() {
        if let data = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(data, forKey: projectsKey)
        }
    }

    private func loadAdminSettings() {
        guard let data = UserDefaults.standard.data(forKey: adminKey),
              let decoded = try? JSONDecoder().decode(AdminSettings.self, from: data) else { return }
        adminSettings = decoded
    }
}
